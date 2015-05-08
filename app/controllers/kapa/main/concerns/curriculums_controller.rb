module Kapa::Main::Concerns::CurriculumsController
  extend ActiveSupport::Concern

  def show
    @curriculum = Kapa::Curriculum.find(params[:id])
    @program = @curriculum.program
    @journey = @curriculum.deserialize(:journey, :as => OpenStruct)
    @transition_points = @curriculum.transition_points
    @enrollments = @curriculum.enrollments
    @person = @curriculum.person
    @person.details(self)
  end

  def update
    @curriculum = Kapa::Curriculum.find(params[:id])
    @curriculum.attributes=(params[:curriculum])
    @curriculum.update_serialized_attributes(:journey, params[:journey]) if params[:journey].present?

    if (params[:return_uri])
      @program = @curriculum.program
      @curriculum.major_primary = @program.major
      @curriculum.distribution = @program.distribution
      @curriculum.track = @program.track
    end

    unless @curriculum.save
      flash[:danger] = @curriculum.errors.full_messages.join(", ")
      if params[:transition_point_id]
        redirect_to kapa_main_transition_point_path(:id => params[:transition_point_id]) and return false
      else
        redirect_to kapa_main_curriculum_path(:id => @curriculum) and return false
      end
    end

    flash[:success] = "Academic record was successfully updated."
    if params[:return_uri]
      redirect_to params[:return_uri]
    else
      if params[:transition_point_id]
        redirect_to kapa_main_transition_point_path(:id => params[:transition_point_id])
      else
        redirect_to kapa_main_curriculum_path(:id => @curriculum)
      end
    end
  end

  def new
    @person = Kapa::Person.find(params[:id])
    @person.details(self)
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @curriculum = @person.curriculums.build(params[:curriculum])
    @curriculum.set_default_options
    @curriculum.update_serialized_attributes(:journey, :active => "Y")

    unless @curriculum.save
      flash[:danger] = @curriculum.errors.full_messages.join(", ")
      redirect_to new_kapa_main_curriculum_path(:id => @person) and return false
    end
    @curriculum.update_serialized_attributes(:journey, :active => "Y")
    redirect_to kapa_main_curriculum_path(:id => @curriculum)
  end

  def index
    @filter = filter
    @curriculums = Kapa::Curriculum.search(@filter).order("persons.last_name, persons.first_name").paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data Kapa::Curriculum.to_csv(@filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "cohort_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

end
