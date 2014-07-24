class Practicum::AssignmentsController < Practicum::BaseController

  def create
    @practicum_placement = PracticumPlacement.find(params[:id])
    @practicum_assignment = @practicum_placement.practicum_assignments.build(params[:practicum_assignment])
    unless @practicum_assignment.save
      @person = @practicum_placement.person
      flash[:notice2] = "Failed to create new assignment record!"
      render_notice and return false
    end
    flash[:notice2] = "Assignment record was successfully created."
    redirect_to practicum_placements_path(:action => :show, :id => @practicum_placement, :focus => params[:focus])
  end

  def update
    @practicum_assignment = PracticumAssignment.find(params[:id])
    @practicum_placement = @practicum_assignment.practicum_placement
    @practicum_assignment.attributes = params[:practicum_assignment][params[:id]]
    unless @practicum_assignment.save
      @person = @practicum_placement.person
      flash[:notice2] = "Failed to update assignment record!"
      render_notice and return false
    end
    flash[:notice2] = "Assignment record was successfully updated."
    render_notice
#    redirect_to practicum_placements_path(:action => :show, :id => @practicum_placement, :focus => params[:focus])
  end
  
  def destroy
    @practicum_assignment = PracticumAssignment.find(params[:id])
    @practicum_placement = @practicum_assignment.practicum_placement
    unless @practicum_assignment.destroy
      flash.now[:notice2] = error_message_for(@practicum_assignment)
      render_notice and return false
    end
    flash[:notice2] = "Assignment record was successfully deleted."
    redirect_to practicum_placements_path(:action => :show, :id => @practicum_placement, :focus => params[:focus])
  end
  
  def list
    @filter = assignment_filter
    @practicum_schools = PracticumSchool.find(:all, :include => :practicum_assignments, :conditions => "practicum_assignments.id is not null", :order => "name_short")
    @practicum_assignments = PracticumAssignment.paginate(:page => params[:page], :per_page => 20, :include => [:person, :practicum_school, {:practicum_placement => [:practicum_profile => :person]}], :conditions => @filter.conditions, :order => "persons.last_name, persons.first_name, practicum_assignments.name")
  end

  def export
    @filter = assignment_filter
    @practicum_assignments = PracticumAssignment.find(:all, :include => [:practicum_school, {:practicum_placement => [:practicum_profile => :person]}], :conditions => @filter.conditions, :order => "persons.last_name, persons.first_name, practicum_assignments.name")
    csv_string = CSV.generate do |csv|
      csv << table_format.collect {|c| c[0]}
      @practicum_assignments.each {|o| csv << table_format(o).collect {|c| c[1]}}
    end
    send_data csv_string,
      :type         => "application/csv",
      :disposition  => "inline",
      :filename     => "mentor_assignments_#{@filter.academic_period_desc}_#{Date.today}.csv"
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
      mentor[:practicum_school_id] = last_assignment.practicum_school_id
      mentor[:content_area] = last_assignment.content_area
#      mentor[:user_primary_id] = last_assignment.user_primary_id
#      mentor[:user_secondary_id] = last_assignment.user_secondary_id
    end
    render :json => mentor
  end

  private
  def table_format(o = nil)
    row = [
      [:id_number, rsend(o, :practicum_placement, :practicum_profile, :person, :id_number)],
      [:last_name, rsend(o, :practicum_placement, :practicum_profile, :person, :last_name)],
      [:first_name, rsend(o, :practicum_placement, :practicum_profile, :person, :first_name)],
      [:email, rsend(o, :practicum_placement, :practicum_profile, :person, :email)],
      [:category, rsend(o, :practicum_placement, :category)],
      [:sequence, rsend(o, :practicum_placement, :sequence)],
      [:mentor_type, rsend(o, :practicum_placement, :mentor_type)],
      [:semester, rsend(o, :practicum_placement, :academic_period_desc)],
      [:status, rsend(o, :practicum_placement, :status)],
      [:total_mentors, rsend(o, :practicum_placement, [:practicum_assignments_select, :mentor], :length)]
    ]
    
    row += [ 
      [:school_name, rsend(o, :practicum_school, :name_short)],
      [:content_area, rsend(o, :content_area)],
      [:mentor_person_id, rsend(o, :person_id)],
      [:mentor_last_name, rsend(o, :person, :last_name)],
      [:mentor_first_name, rsend(o, :person, :first_name)],
      [:mentor_email, rsend(o, :person, :contact, :email)],
      [:school_code, rsend(o, :practicum_school, :code)],
      [:school_name, rsend(o, :practicum_school, :name_short)],
      [:content_area, rsend(o, :content_area)],
      [:supervisor_1_uid, rsend(o, :user_primary, :uid)],
      [:supervisor_1_last_name, rsend(o, :user_primary, :person, :last_name)],
      [:supervisor_1_first_name, rsend(o, :user_primary, :person, :first_name)],
      [:supervisor_2_uid, rsend(o, :user_secondary, :uid)],
      [:supervisor_2_last_name, rsend(o, :user_secondary, :person, :last_name)],
      [:supervisor_2_first_name, rsend(o, :user_secondary, :person, :first_name)],
      [:note, rsend(o, :note)]
    ]
    return row
  end

  def assignment_filter
    f = filter
    f.append_condition "practicum_assignments.assignment_type = 'mentor'"
    f.append_condition "practicum_placements.academic_period = ?", :academic_period
    f.append_condition "practicum_assignments.practicum_school_id = ?", :practicum_school_id
    f.append_condition "#{@current_user.id} in (practicum_placements.user_primary_id, practicum_placements.user_secondary_id)" unless @current_user.manage?
    return f
  end
end
