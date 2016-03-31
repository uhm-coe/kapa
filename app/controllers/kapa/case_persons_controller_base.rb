module Kapa::CasePersonsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_person = Kapa::CasePerson.find(params[:id])
    @case = @case_person.case
    if @case_person.internal?
      @case_person_profile = @case_person.person
      @case_person_contact =  @case_person_profile.contact if @case_person_profile.contact
    else
      @case_person_profile = @case_person.deserialize(:person_profile, :as => OpenStruct)
      @case_person_contact = @case_person.deserialize(:person_contact, :as => OpenStruct)
    end
    @person = @case.person
    @contact =  @person.contact
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @person = @case.person
    @contact =  @person.contact
  end

  def create
    @case = Kapa::Case.find(params[:case_id])
    @case_person = @case.case_persons.build(case_person_params)
    if params[:case_person][:person_id]

    else
      @case_person.serialize(:person_profile, case_person_profile_params) if params[:case_person_profile]
      @case_person.serialize(:person_contact, case_person_contact_params) if params[:case_person_contact]
    end

    unless @case_person.save
      flash[:danger] = error_message_for(@case_person)
      redirect_to kapa_case_path(:id => @case_person.case, :anchor => "case_persons") and return false
    end

    flash[:success] = "Person was successfully added."
    redirect_to kapa_case_path(:id => @case, :anchor => "case_persons")
  end

  def update
    @case_person = Kapa::CasePerson.find(params[:id])
    @case = @case_person.case
    @person = @case.person
    @contact =  @person.contact

    if @case_person.internal?
      @case_person_profile = @case_person.person
      @case_person_contact =  @case_person_profile.contact ||= @case_person_profile.build_contact
      @case_person_profile.attributes = case_person_profile_params if params[:case_person_profile]
      @case_person_contact.attributes = case_person_contact_params if params[:case_person_contact]
      unless @case_person_profile.save and @case_person_contact.save
        flash[:danger] = error_message_for(@case_person_profile, @case_person_contact)
        redirect_to kapa_case_person_path(:id => @case_person) and return false
      end
    else
      @case_person.serialize(:person_profile, case_person_profile_params) if params[:case_person_profile]
      @case_person.serialize(:person_contact, case_person_contact_params) if params[:case_person_contact]
    end

    @case_person.attributes = case_person_params
    unless @case_person.save
      flash[:danger] = error_message_for(@case_person)
      redirect_to kapa_case_person_path(:id => @case_person) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_case_path(:id => @case, :anchor => "case_persons")
  end

  def destroy
    @case_person = Kapa::CasePerson.find(params[:id])
    @case = @case_person.case
    unless @case_person.destroy
      flash[:danger] = error_message_for(@case_person)
      redirect_to kapa_case_path(:id => @case, :anchor => "case_persons") and return false
    end
    flash[:success] = "Person was successfully deleted."
    redirect_to kapa_case_path(:id => @case, :anchor => "case_persons")
  end

  private
  def case_person_params
    params.require(:case_person).permit(:case_id, :type, :person_id, :note, :sequence)
  end

  def case_person_profile_params
    params.require(:case_person_profile).permit(:id_number, :last_name, :middle_initial, :birth_date, :ssn, :ssn_agreement,
                                    :email, :first_name, :other_name, :title, :gender, :status)
  end

  def case_person_contact_params
    params.require(:case_person_contact).permit(:cur_phone, :mobile_phone, :email, :cur_street, :cur_city, :cur_state,
                                    :cur_postal_code, :per_street, :per_city, :per_state, :per_postal_code)
  end
end
