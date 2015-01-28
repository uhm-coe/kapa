class Kapa::Main::PersonsController < Kapa::Main::BaseController

  def show
    f = ApplicationFilter.new
    f.append_depts_condition("dept like ?", @current_user.depts)
    @person = Person.find(params[:id])
    @person.details(self)
    @advising_sessions = @person.advising_sessions.find(:all, :conditions => f.conditions, :order => "session_date DESC")
    @curriculums = @person.curriculums.find(:all, :include => {:transition_points => :term}, :order => "terms.sequence DESC")
    @course_registrations = CourseRegistration.includes(:course => :term).where(["person_id = ?", @person.id]).order("terms.sequence DESC")
    @practicum_profiles = @person.practicum_profiles

    if (params[:doc_id])
      @document = Document.find(params[:doc_id])
      @title = @document.name
      render :partial => "/artifact/documents/edit", :layout => false
    elsif (params[:form_id])
      @form = Form.find(params[:form_id])
      @title = @form.type_desc
      render :partial => "/artifact/forms/edit", :layout => false
    end
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
      flash[:success] = "Person was successfully created."

    when "consolidate"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person)
      @person = @person_verified
      flash[:success] = "Person was successfully consolidated."
    else
      flash[:success] = "Person was successfully created."
    end

    unless @person.save
      flash[:success] = nil
      flash[:danger] = error_message_for(@person)
      redirect_to new_kapa_main_person_path and return false
    end
    redirect_to kapa_main_person_path(:id => @person)
  end

  def update
    @person = Person.find(params[:id])
    case params[:mode]
    when "promote"
      @person.attributes = (params[:person])
      @person.promote
      unless @person.save
        flash[:danger] = error_message_for(@person)
        redirect_to kapa_main_person_path(:id => @person) and return false
      end
      flash[:success] = "Person was successfully verified."
      params[:return_uri][:focus] = params[:focus]
      redirect_to params[:return_uri]

    when "consolidate"
      @person_verified = Person.search(:first, params[:person][:id_number], :verified => true)
      @person_verified.merge(@person, :include_associations => true)
      @person = @person_verified
      unless @person.save
        flash[:danger] = error_message_for(@person)
        redirect_to kapa_main_person_path(:id => @person) and return false
      end

      flash[:success] = "Person was successfully consolidated."
      params[:return_uri][:id] = @person.id if params[:return_uri][:controller] == "main/persons"  #This is needed for requests comes from outside of main
      params[:return_uri][:focus] = params[:focus]
      redirect_to params[:return_uri]

    else
      @person.attributes = (params[:person])
      unless @person.save
        flash[:danger] = error_message_for(@person)
        redirect_to kapa_main_person_path(:id => @person) and return false
      end
      flash[:success] = "Person was successfully updated."
      redirect_to kapa_main_person_path(:id => @person)
    end
  end

  def index
    @filter = filter
    @persons = Person.search(:all, @filter.key)
    @modal = true if filter.key.blank?
    if @persons.blank?
      flash[:warning] = "No record was found."
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
        flash[:info] = "Person was verified with the UH Directory.  Please check the name and save this record."
      else
        @mode = :consolidate
        flash[:warning] = "This person already exists in the system.  Please check the name and click save to use the exisiting record."
      end
    else
      flash[:warning] = "No record was found in UH Directory. Please check ID or UH Email"
    end
    render :partial => "/main/person_form", :layout => false
  end

  def sync
    @person = Person.find(params[:id])
    key = params[:key]
    @person_verified = DirectoryService.person(key)

    if @person_verified
      @person.id_number = @person_verified.id_number
      @person.email = @person_verified.email
      @person.email_alt = @person_verified.email_alt
      @person.first_name = @person_verified.first_name
      @person.last_name = @person_verified.last_name
      flash[:success] = "Record was updated from UH Directory.  Please check the name and click save to use the new record."
    end
    render :partial => "/main/person_form", :layout => false
  end
end
