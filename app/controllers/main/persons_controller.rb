class Main::PersonsController < Main::BaseController

  def show
    f = ApplicationFilter.new
    f.append_depts_condition("dept like ?", @current_user.depts)
    @person = Person.find(params[:id])
    @person.details(self)
    @advising_sessions = @person.advising_sessions.find(:all, :conditions => f.conditions, :order => "session_date DESC")
    @curriculums = @person.curriculums.find(:all, :include => :transition_points, :order => "academic_period DESC")
    @assessment_course_registrations = AssessmentCourseRegistration.includes(:assessment_course).where(["person_id = ?", @person.id]).order("assessment_courses.academic_period DESC")
    @practicum_profiles = @person.practicum_profiles
  end

  def new
    @person = Person.new :source => "Manual"
  end

  def create
    @person = Person.new(params[:person])
    case params[:mode]
    when "promote"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:notice1] = "Person was successfully created."

    when "consolidate"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:notice1] = "Person was successfully consolidated."

    else
      flash[:notice1] = "Person was successfully created."
    end

    unless @person.save
      flash.now[:notice1] = error_message_for(@person)
      render_notice and return false
    end

    redirect_to :action => :show, :id => @person
  end

  def update
    @person = Person.find(params[:id])
    case params[:mode]
    when "promote"
      @person.attributes=(params[:person])
      @person.promote
      unless @person.save
        flash.now[:notice1] = error_message_for(@person)
        render_notice and return false
      end
      flash[:notice1] = "Person was successfully verified."
      params[:return_uri][:focus] = params[:focus]
      redirect_to params[:return_uri]

    when "consolidate"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person, :include_associations => true)
      @person = @person_verified
      unless @person.save
        flash.now[:notice1] = error_message_for(@person)
        render_notice and return false
      end

      flash[:notice1] = "Person was successfully consolidated."
      params[:return_uri][:id] = @person.id if params[:return_uri][:controller] == "main/persons"  #This is needed for requests comes from outside of main
      params[:return_uri][:focus] = params[:focus]
      redirect_to params[:return_uri]

    else
      @person.attributes=(params[:person])
      unless @person.save
        flash.now[:notice1] = error_message_for(@person)
        render_notice and return false
      end
      flash[:notice1] = "Person was successfully updated."
      render_notice
    end
  end

  def index
    @filter = filter
    @persons = Person.search(:all, @filter.key)

    if @persons.blank?
      flash.now[:notice] = "No record was found."
    end
  end

  def verify
    if params[:id]
      @person = Person.find(params[:id])
    else
      @person = Person.new
    end

    key = params[:key]
    @person_verified = Person.search :first, key, :verified => true

    if @person_verified
      @person.id_number = @person_verified.id_number
      @person.email = @person_verified.email
      @person.email_alt = @person_verified.email_alt
      @person.first_name = @person_verified.first_name
      @person.last_name = @person_verified.last_name

      if @person_verified.new_record?
        @mode = :promote
        flash.now[:person_notice] = "Person was verified with the UH Directory.  Please check the name and save this record."
      else
        @mode = :consolidate
        flash.now[:person_notice] = "This person already exists in the system.  Please check the name and click save to use the exisiting record."
      end
    else
      flash.now[:person_notice] = "No record was found in UH Directory. Please check ID or UH Email"
    end
    render :partial => "/main/person_form", :layout => false
  end

  def sync
    @person = Person.find(params[:id])
    key = params[:key]
    @person_verified = Person.find_by_ldap :first, key
    
    if @person_verified
      @person.id_number = @person_verified.id_number
      @person.email = @person_verified.email
      @person.email_alt = @person_verified.email_alt
      @person.first_name = @person_verified.first_name
      @person.last_name = @person_verified.last_name
      flash.now[:person_notice] = "Record was updated from UH Directory.  Please check the name and click save to use the new record."
    end
    render :partial => "/main/person_form", :layout => false
  end
end
