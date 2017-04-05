module Kapa::CurriculumsControllerBase
  extend ActiveSupport::Concern

  def show
    @curriculum = Kapa::Curriculum.find(params[:id])
    @curriculum_ext = @curriculum.ext
    @program = @curriculum.program
    @journey = @curriculum.deserialize(:journey, :as => OpenStruct)
    @transition_points = @curriculum.transition_points
    @enrollments = @curriculum.enrollments
    @person = @curriculum.person
    @person_ext = @person.ext
  end

  def update
    @curriculum = Kapa::Curriculum.find(params[:id])
    @curriculum.attributes = curriculum_params if params[:curriculum]
    @curriculum.update_serialized_attributes!(:_ext, params[:curriculum_ext]) if params[:curriculum_ext].present?
    @curriculum.update_serialized_attributes(:journey, params[:journey]) if params[:journey].present?

    unless @curriculum.save
      flash[:danger] = @curriculum.errors.full_messages.join(", ")
      redirect_to kapa_curriculum_path(:id => @curriculum) and return false
    end

    flash[:success] = "Academic record was successfully updated."
    redirect_to kapa_curriculum_path(:id => @curriculum)
  end

  def new
    @person = Kapa::Person.find(params[:id])
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @curriculum = @person.curriculums.build(curriculum_params)
    @curriculum.set_default_options
    @curriculum.update_serialized_attributes(:journey, :active => "Y")

    unless @curriculum.save
      flash[:danger] = @curriculum.errors.full_messages.join(", ")
      redirect_to new_kapa_curriculum_path(:id => @person) and return false
    end
    @curriculum.update_serialized_attributes(:journey, :active => "Y")
    redirect_to kapa_curriculum_path(:id => @curriculum)
  end

  def index
    @filter = filter
    @curriculums = Kapa::Curriculum.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::Curriculum.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "cohort_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}.csv"
  end

  private
  def curriculum_params
    params.require(:curriculum).permit(:program_id, :second_degree, :track, :distribution, :location, :major_primary,
                                       :major_secondary, :person_id, :term_id, :note, :user_ids => [])
  end

end
