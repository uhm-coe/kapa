module Kapa::PersonsControllerBase
  extend ActiveSupport::Concern

  def show
    @person = Kapa::Person.find(params[:id])
    @person_ext = @person.ext
    #TODO add public or dept conditions
    @documents = []
    @documents += @person.files
    @documents += @person.forms
    @documents += @person.exams
    @curriculums = @person.curriculums.eager_load(:transition_points => :term).order("terms.sequence DESC")
    @advising_sessions = @person.advising_sessions.order("session_date DESC")
    @case_involvements = @person.case_involvements.eager_load(:case).order("cases.reported_at DESC")
    @course_registrations = @person.course_registrations.eager_load(:course => :term).order("terms.sequence DESC")
    @practicum_placements = @person.practicum_placements
    @publications = @person.faculty_publications
    @service_activities = @person.faculty_service_activities
    @awards = @person.faculty_awards
  end

  def new
    @person = Kapa::Person.new :source => "Manual"
  end

  def create
    @person = Kapa::Person.new(person_params)
    unless @person.save
      flash[:success] = nil
      flash[:danger] = error_message_for(@person)
      redirect_to new_kapa_person_path and return false
    end
    flash[:success] = "Person was successfully created."
    redirect_to kapa_person_path(:id => @person)
  end

  def update
    @person = Kapa::Person.find(params[:id])

    if params[:person_id_verified]
      @person_verified = Kapa::Person.find(params[:person_id_verified])
      @person_verified.merge(@person, :include_associations => true)
      flash[:success] = "Person was successfully merged."
      params[:return_path][:id] = @person_verified.id if params[:return_path][:controller] == "kapa/main/persons"  #This is needed for requests comes from outside of main
      params[:return_path][:anchor] = params[:anchor]
      redirect_to params[:return_path]
    else
      @person.attributes = person_params
      @person.update_serialized_attributes!(:_ext, params[:person_ext]) if params[:person_ext].present?
      unless @person.save
        flash[:danger] = error_message_for(@person)
        redirect_to kapa_person_path(:id => @person) and return false
      end
      flash[:success] = "Person was successfully updated."
      redirect_to kapa_person_path(:id => @person)
    end
  end

  def index
    @filter = filter
    if params[:modal]
      @modal = true
      @persons = Kapa::Person.where("0=1")
    else
      @persons = Kapa::Person.search(:filter => @filter)
    end

    if @persons.blank?
      person = Kapa::Person.lookup(@filter.key)
      if person
        person.save!
        @persons = [person]
        flash.now[:success] = "The record was imported from #{person.source}."
      else
        flash.now[:warning] = "No record was found."
      end
    end

    respond_to do |format|
      format.html
      format.json { render :json => {:persons => @persons.collect {|p| {:person_id => p.id, :id_number => p.id_number, :full_name => p.full_name, :email => p.email}}} }
    end
  end

  def lookup
    person = Kapa::Person.lookup(params[:key])
    if person
      if person.new_record?
        action = "promote"
      elsif params[:id] != person.id.to_s
        action = "merge"
        person_id_verified = person.id
        redirect_path = kapa_person_path(:id => person)
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
    render :partial => "kapa/persons/person_form", :layout => false
  end

  private
  def person_params
    params.require(:person).permit(:birth_date, :business_phone, :created_at, :cur_city, :cur_phone, :cur_postal_code, :cur_state, :cur_street, :dept, :email, :email_alt, :ethnicity, :ets_id, :fax, :first_name, :gender, :id, :id_number, :last_name, :middle_initial, :mobile_phone, :note, :other_name, :per_city, :per_phone, :per_postal_code, :per_state, :per_street, :source, :ssn, :ssn_agreement, :ssn_crypted, :status, :title, :type, :uid, :updated_at)
  end
end
