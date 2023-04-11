module Kapa::PersonsControllerBase
  extend ActiveSupport::Concern

  included do
    before_action :remember_return_path, :only => :show
  end

  def show
    options= {:filter => {:user => @current_user}}
    @person = Kapa::Person.find(params[:id])
    @person_ext = @person.ext
    @documents = []
    @documents += @person.files.search(options)
    @documents += @person.forms.search(options)
    @documents += @person.texts.search(options)
    @form_templates = Kapa::FormTemplate.all
    @text_templates = Kapa::TextTemplate.all
  end

  def new
    @person = Kapa::Person.new :source => "Manual"
  end

  def create
    @person = Kapa::Person.new(person_params)
    unless @person.save
      flash[:notice] = nil
      flash[:alert] = error_message_for(@person)
      redirect_to new_kapa_person_path and return false
    end
    flash[:notice] = "Person was successfully created."
    redirect_to kapa_person_path(:id => @person)
  end

  def update
    @person = Kapa::Person.find(params[:id])

    if params[:person_id_verified].present?
      @person_verified = Kapa::Person.find(params[:person_id_verified])
      @person_verified.merge(@person, :include_associations => true)
      flash[:notice] = "Person was successfully merged."
      redirect_to(kapa_person_path(:id => @person_verified))  #When person is merged, always redirect to the verified person record.
    else
      @person.attributes = person_params
      @person.update_serialized_attributes!(:_ext, params[:person_ext]) if params[:person_ext].present?
      unless @person.save
        flash[:alert] = error_message_for(@person)
        redirect_to kapa_person_path(:id => @person) and return false
      end
      flash[:notice] = "Person was successfully updated."
      redirect_to(params[:return_path] || kapa_person_path(:id => @person))
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
        flash.now[:notice] = "The record was imported from #{person.source}."
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
    json = {}
    if person
      if person.new_record?
        json[:action] = "promote"
        json[:person] = person.attributes.slice('id_number', 'first_name', 'last_name', 'status', 'email')
        json[:notice] = "Person was verified with the external directory.  Please check the name and save this record."
      elsif params[:id] != person.id.to_s
        json[:action] = "merge"
        json[:person] = person.attributes.slice('id_number', 'first_name', 'last_name', 'status', 'email')
        json[:person_id_verified] = person.id
        json[:redirect_path] = kapa_person_path(:id => person)
        json[:notice] = "This person already exists in this system.  Please check the name and click OK to merge this record."
      end
      render(:json => json)
    else
      json[:action] = "alert"
      json[:notice] = "Unable to find the record in the external directory. Please check ID or Email."
      render(:json => json, :status => :unprocessable_entity)
    end
  end

  def sync
    @person = Kapa::Person.find(params[:id])
    @person_ext = @person.ext
    key = params[:key]
    @person_remote = Kapa::Person.lookup_remote(key)
    json = {}
    if @person_remote
      @person.id_number = @person_remote.id_number if @person_remote.id_number
      @person.email = @person_remote.email if @person_remote.email
      @person.email_alt = @person_remote.email_alt if @person_remote.email_alt
      @person.first_name = @person_remote.first_name if @person_remote.first_name
      @person.last_name = @person_remote.last_name if @person_remote.last_name
      json[:html] = render_to_string(:partial => "kapa/persons/person_form")
      json[:notice] = "Record was updated from the remote source. Please check the records and click OK to save the record."
      render :json => json
    else
      json[:notice] = "System was unable to update this record with the remote resource."
      render :json => json, :status => :unprocessable_entity
    end
  end

  private
  def person_params
    params.require(:person).permit(:birth_date, :business_phone, :created_at, :cur_city, :cur_phone, :cur_postal_code, :cur_state, :cur_street, :dept, :email, :email_alt, :ethnicity, :ets_id, :fax, :first_name, :gender, :id, :id_number, :last_name, :middle_initial, :mobile_phone, :note, :other_name, :per_city, :per_phone, :per_postal_code, :per_state, :per_street, :source, :status, :title, :type, :uid, :updated_at, :dept, :depts => [])
  end
end
