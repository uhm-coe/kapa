class Kapa::Practicum::PlacementsController < Kapa::Practicum::BaseController

  def show
    @practicum_placement = PracticumPlacement.find(params[:id])
    @person = @practicum_placement.person
    @person.details(self)
    @curriculums = @person.curriculums
    @practicum_sites = PracticumSite.select("id, name_short")
    @mentors = Person.includes(:contact).where("id in (SELECT distinct person_id FROM practicum_placements)").order("persons.last_name, persons.first_name")
  end

  def new
    @person = Person.find(params[:id])
    @person.details(self)
    @practicum_placement = @person.practicum_placements.build(:term_id => Term.current_term.id)
    @curriculums = @person.curriculums
  end


  def create
    @practicum_placement = PracticumPlacement.find(params[:id])
    @practicum_assignment = @practicum_placement.practicum_assignments.build(params[:practicum_assignment])

    if @practicum_assignment.save
      flash[:success] = "Assignment record was successfully created."
    else
      @person = @practicum_placement.person
      flash[:danger] = "Failed to create new assignment record."
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement, :focus => params[:focus])
  end

  def update
    @practicum_placement = PracticumPlacement.find(params[:id])
    @practicum_placement.attributes = params[:practicum_placement]

    if @practicum_placement.save
      flash[:success] = "Placement record was successfully updated."
    else
      @person = @practicum_placement.person
      flash[:danger] = "Failed to update placement record."
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement)
  end

  def destroy
    @practicum_assignment = PracticumAssignment.find(params[:id])
    @practicum_placement = @practicum_assignment.practicum_placement

    if @practicum_assignment.destroy
      flash[:success] = "Assignment record was successfully deleted."
    else
      flash[:danger] = error_message_for(@practicum_assignment)
    end
    redirect_to kapa_practicum_placement_path(:id => @practicum_placement, :focus => params[:focus])
  end

  def index
    @filter = filter
    @per_page_selected = @filter.per_page || Rails.configuration.items_per_page
    # TODO: Check @practicum_sites
    @practicum_sites = PracticumSite.includes(:practicum_placement).where{practicum_placements.id != nil}.order("name_short")
    @practicum_placements = PracticumPlacement.search(@filter).order("persons.last_name, persons.first_name").paginate(:page => params[:page], :per_page => @per_page_selected)
  end

  def export
    @filter = filter
    logger.debug "----filter: #{filter.inspect}"
    send_data PracticumPlacement.to_csv(@filter),
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "mentor_assignments_#{Term.find(@filter.term_id).description if @filter.term_id.present?}_#{Date.today}.csv"
  end

  def get_mentor
    person = Person.find(params[:person_id])
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
      person = Person.new(:source => "Placement")
    else
      person = Person.find(params[:mentor][:person_id])
    end
    person.last_name = params[:mentor][:last_name]
    person.first_name = params[:mentor][:first_name]
    person.save
    contact = person.contact ||= person.build_contact
    contact.email = params[:mentor][:email].downcase
    contact.save
    last_assignment = PracticumAssignment.first(:conditions => ["person_id = ?", person.id], :order => "id desc")

    mentor = {}
    mentor[:person_id] = person.id
    mentor[:full_name] = person.full_name
    if last_assignment
      mentor[:practicum_site_id] = last_assignment.practicum_site_id
      mentor[:content_area] = last_assignment.content_area
#      mentor[:user_primary_id] = last_assignment.user_primary_id
#      mentor[:user_secondary_id] = last_assignment.user_secondary_id
    end
    render :json => mentor
  end

end
