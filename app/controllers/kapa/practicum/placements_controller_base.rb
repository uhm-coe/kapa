module Kapa::Practicum::PlacementsControllerBase
  extend ActiveSupport::Concern

  def show
    @practicum_placement = Kapa::PracticumPlacement.find(params[:id])
    @person = @practicum_placement.person
    @person.details(self)
    @curriculums = @person.curriculums
    @practicum_sites = Kapa::PracticumSite.select("id, name_short")
    @mentors = Kapa::Person.eager_load(:contact).where("id in (SELECT distinct mentor_person_id FROM practicum_placements)").order("persons.last_name, persons.first_name")
  end

  def new
    @person = Kapa::Person.find(params[:id])
    @person.details(self)
    @practicum_placement = @person.practicum_placements.build(:term_id => Kapa::Term.current_term.id)
    @curriculums = @person.curriculums
  end

  def create
    @practicum_placement = Kapa::PracticumPlacement.new practicum_placement_params
    @practicum_placement.person_id = params[:id]

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
    redirect_to kapa_main_person_path(:id => @practicum_placement.person)
  end

  def index
    @filter = filter
    @practicum_sites = Kapa::PracticumSite.eager_load(:practicum_placements).order("name_short")
    @practicum_placements = Kapa::PracticumPlacement.search(:filter => @filter).paginate(:page => params[:page], :per_page => @filter.per_page)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{@filter.inspect}"
    send_data Kapa::PracticumPlacement.to_csv(:filter => @filter),
              :type => "application/csv",
              :disposition => "inline",
              :filename => "placements_#{Kapa::Term.find(@filter.term_id).description if @filter.term_id.present?}_#{Date.today}.csv"
  end

  def get_mentor
    person = Kapa::Person.find(params[:person_id])
    mentor = {}
    mentor[:last_name] = person.last_name
    mentor[:first_name] = person.first_name
    if person.contact
      mentor[:email] = person.contact.email
    else
      mentor[:email] = ""
    end
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
    person.save
    contact = person.contact ||= person.build_contact
    contact.email = params[:mentor][:email].downcase
    contact.save
    mentor = {}
    mentor[:person_id] = person.id
    mentor[:full_name] = person.full_name
    render :json => mentor
  end

  private
  def practicum_placement_params
    params.require(:practicum_placement).permit(:term_id, :curriculum_id)
  end
end
