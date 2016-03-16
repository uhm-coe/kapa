module Kapa::PersonAssignmentsControllerBase
  extend ActiveSupport::Concern

  def show
    @person_assignment = Kapa::PersonAssignment.find(params[:id])
    @person = @person_assignment.person
    @contact =  @person.contact
    @assignable = @person_assignment.assignable
  end

  def new
  end

  def create
    @person_assignment = Kapa::PersonAssignment.new(person_assignment_params)
    unless @person_assignment.save
      flash[:danger] = error_message_for(@person_assignment)
      redirect_to kapa_case_path(:id => @person_assignment.assignable) and return false
    end

    flash[:success] = "Person was successfully added."
    redirect_to kapa_person_assignment_path(:id => @person_assignment)
  end

  def update
    @person_assignment = Kapa::PersonAssignment.find(params[:id])
    @person = @person_assignment.person
    @contact =  @person.contact

    @person_assignment.attributes = person_assignment_params
    @person.attributes = person_params if params[:person]
    @contact.attributes = contact_params if params[:contact]

    unless @person_assignment.save and @person.save and @contact.save
      flash[:danger] = error_message_for(@person_assignment, @person, @contact)
      redirect_to kapa_assignment_path(:id => @person_assignment) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_person_assignment_path(:id => @person_assignment, :return_path => params[:return_path])
  end

  def destroy
    @person_assignment = Kapa::PersonAssignment.find(params[:id])
    @assignable = @person_assignment.assignable
    unless @person_assignment.destroy
      flash[:danger] = error_message_for(@person_assignment)
      redirect_to kapa_assignable_path(:id => @assignable) and return false
    end
    flash[:success] = "Person was successfully deleted."
    redirect_to kapa_assignable_path(:id => @assignable, :anchor => "involved_person")
  end

  def export
  end

  private
  def person_assignment_params
    params.require(:person_assignment).permit(:assignable_id, :assignable_type, :type, :person_id, :note, :sequence)
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
