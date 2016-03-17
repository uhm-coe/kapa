module Kapa::CasePersonsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_person = Kapa::CasePerson.find(params[:id])
    @case = @case_person.case
    @person = @case_person.person
    @contact =  @person.contact
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @person = @case.person
    @contact =  @person.contact
  end

  def create
    @case_person = Kapa::CasePerson.new(case_person_params)
    unless @case_person.save
      flash[:danger] = error_message_for(@case_person)
      redirect_to kapa_case_path(:id => @case_person.case) and return false
    end

    flash[:success] = "Person was successfully added."
    redirect_to kapa_case_person_path(:id => @case_person)
  end

  def update
    @case_person = Kapa::CasePerson.find(params[:id])
    @person = @case_person.person
    @contact =  @person.contact ||= @person.build_contact

    @case_person.attributes = case_person_params
    @person.attributes = person_params if params[:person]
    @contact.attributes = contact_params if params[:contact]

    unless @case_person.save and @person.save and @contact.save
      flash[:danger] = error_message_for(@case_person, @person, @contact)
      redirect_to kapa_assignment_path(:id => @case_person) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_case_person_path(:id => @case_person, :return_path => params[:return_path])
  end

  def destroy
    @case_person = Kapa::CasePerson.find(params[:id])
    @case = @case_person.case
    unless @case_person.destroy
      flash[:danger] = error_message_for(@case_person)
      redirect_to kapa_case_path(:id => @case) and return false
    end
    flash[:success] = "Person was successfully deleted."
    redirect_to kapa_case_path(:id => @case, :anchor => "involved_person")
  end

  def export
  end

  private
  def case_person_params
    params.require(:case_person).permit(:case_id, :type, :person_id, :note, :sequence)
  end

  def person_params
    params.require(:person).permit(:id_number, :last_name, :middle_initial, :birth_date, :ssn, :ssn_agreement,
                                    :email, :first_name, :other_name, :title, :gender, :status)
  end

  def contact_params
    params.require(:contact).permit(:cur_phone, :mobile_phone, :email, :cur_street, :cur_city, :cur_state,
                                    :cur_postal_code, :per_street, :per_city, :per_state, :per_postal_code)
  end
end
