module Kapa::PracticumPlacementsControllerBase
  extend ActiveSupport::Concern

  def show
    @practicum_placement = Kapa::PracticumPlacement.find(params[:id])
    @practicum_placement_ext = @practicum_placement.ext
    @practicum_logs = @practicum_placement.practicum_logs
    @person = @practicum_placement.person
    @person_ext = @person.ext
    @mentors = Kapa::Person.where("persons.id in (SELECT distinct mentor_person_id FROM practicum_placements)").order("persons.last_name, persons.first_name")
    @curriculums = @person.curriculums
    @practicum_sites = Kapa::PracticumSite.select("id, name_short")
  end

  def new
    @person = Kapa::Person.find(params[:person_id])
    @curriculums = @person.curriculums
    default_curriculum = @curriculums.first.id if @curriculums.present?
    @practicum_placement = @person.practicum_placements.build(:start_term_id => Kapa::Term.current_term.id, :end_term_id => Kapa::Term.current_term.id, :curriculum_id => default_curriculum)
  end

  def create
    @person = Kapa::Person.find(params[:id])
    @practicum_placement = @person.practicum_placements.build(practicum_placement_params)
    logger.debug "*DEBUG  #{@person.inspect}"
    if @practicum_placement.save
      flash[:success] = "Placement record was successfully created."
    else
      @person = @practicum_placement.person
      flash[:danger] = "Failed to create new placement record."
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement)
  end

  def update
    @practicum_placement = Kapa::PracticumPlacement.find(params[:id])
    @practicum_placement.attributes = practicum_placement_params
    @practicum_placement.update_serialized_attributes!(:_ext, params[:practicum_placement_ext]) if params[:practicum_placement_ext].present?

    if @practicum_placement.save
      flash[:success] = "Placement record was successfully updated."
    else
      @person = @practicum_placement.person
      flash[:danger] = "Failed to update placement record."
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement)
  end

  def destroy
    @practicum_placement = Kapa::PracticumPlacement.find(params[:id])

    if @practicum_placement.destroy
      flash[:success] = "Placement record was successfully deleted."
    else
      flash[:danger] = "Failed to delete placement record."
    end
    redirect_to kapa_person_path(:id => @practicum_placement.person)
  end

  def index
    @filter = filter
    @practicum_sites = Kapa::PracticumSite.eager_load(:practicum_placements).order("name_short")
    @practicum_placements = Kapa::PracticumPlacement.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    send_data Kapa::PracticumPlacement.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "placements_#{Kapa::Term.find(@filter.term_id).description}_#{Date.today}.csv"
  end

  def get_mentor
    person = Kapa::Person.find(params[:person_id])
    mentor = {}
    mentor[:last_name] = person.last_name
    mentor[:first_name] = person.first_name
    mentor[:email] = person.email_alt
    render :json => mentor
  end

  def update_mentor
    if params[:mentor][:person_id].blank?
      person = Kapa::Person.new(:source => "Placement")
    else
      person = Kapa::Person.find(params[:mentor][:person_id])
    end
    person.last_name = params[:mentor][:last_name]
    person.first_name = params[:mentor][:first_name]
    person.email_alt = params[:mentor][:email].downcase
    person.save
    mentor = {}
    mentor[:person_id] = person.id
    mentor[:full_name] = person.full_name
    render :json => mentor
  end

  private
  def practicum_placement_params
    params.require(:practicum_placement).permit(:start_term_id, :end_term_id, :person_id, :mentor_person_id, :curriculum_id, :practicum_site_id, :type, :category, :note, :user_ids => [])
  end
end
