module Kapa::Main::PersonsControllerBase
  extend ActiveSupport::Concern

  def show
    @person = Kapa::Person.find(params[:id])
    @person.details(self)
    #TODO Add dept conditions
    @curriculums = @person.curriculums.eager_load(:transition_points => :term).order("terms.sequence DESC")
    @advising_sessions = @person.advising_sessions.order("session_date DESC")
    @course_registrations = Kapa::CourseRegistration.eager_load(:course_offer => :term).where(:person_id => @person).order("terms.sequence DESC")
    @practicum_placements = @person.practicum_placements

    if (params[:doc_id])
      @file = Kapa::File.find(params[:doc_id])
      @title = @file.name
      render :partial => "/kapa/artifact/documents/edit", :layout => false
    elsif (params[:form_id])
      @form = Kapa::Form.find(params[:form_id])
      @title = @form.type_desc
      render :partial => "/kapa/artifact/forms/edit", :layout => false
    end
  end

  def new
    @person = Kapa::Person.new :source => "Manual"
  end

  def create
    @person = Kapa::Person.new(params[:person])
    unless @person.save
      flash[:success] = nil
      flash[:danger] = error_message_for(@person)
      redirect_to new_kapa_main_person_path and return false
    end
    flash[:success] = "Person was successfully created."
    redirect_to kapa_main_person_path(:id => @person)
  end

  def update
    @person = Kapa::Person.find(params[:id])

    # TODO: Review merge process (commented out for now, until reviewed and working properly)
    # if params[:person_id_verified]
    #   @person_verified = Kapa::Person.find(params[:person_id_verified])
    #   @person_verified.merge(@person, :include_associations => true)
    #   flash[:success] = "Person was successfully merged."
    #   params[:return_uri][:id] = @person_verified.id if params[:return_uri][:controller] == "kapa/main/persons"  #This is needed for requests comes from outside of main
    #   params[:return_uri][:focus] = params[:focus]
    #   redirect_to params[:return_uri]

    # else
    @person.attributes = params[:person]
    unless @person.save
      flash[:danger] = error_message_for(@person)
      redirect_to kapa_main_person_path(:id => @person) and return false
    end
    flash[:success] = "Person was successfully updated."
    redirect_to kapa_main_person_path(:id => @person)
    # end
  end

  def index
    @filter = filter
    if @filter.key.blank?
      @modal = true
      @persons = Kapa::Person.where("0=1")
    else
      @persons = Kapa::Person.search(@filter)
    end
  end

  def lookup
    person = Kapa::Person.lookup(params[:key], :verified => true)
    if person
      if person.new_record?
        action = "promote"
      elsif params[:id] != person.id.to_s
        action = "merge"
        person_id_verified = person.id
        redirect_path = kapa_main_person_path(:id => person)
      end
    else
        action = "alert"
    end
    render(:json => {:person => person, :action => action, :person_id_verified => person_id_verified, :redirect_path => redirect_path})
  end

  def sync
    @person = Kapa::Person.find(params[:id])
    key = params[:key]
    @person_verified = Kapa::Person.import(key)

    if @person_verified
      @person.id_number = @person_verified.id_number
      @person.email = @person_verified.email
      @person.email_alt = @person_verified.email_alt
      @person.first_name = @person_verified.first_name
      @person.last_name = @person_verified.last_name
      flash[:success] = "Record was updated from UH Directory.  Please check the name and click save to use the new record."
    end
    render :partial => "/kapa/main/person_form", :layout => false
  end
end
