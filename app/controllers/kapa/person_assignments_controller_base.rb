module Kapa::PersonAssignmentsControllerBase
  extend ActiveSupport::Concern

  def show
    @person_assignment = Kapa::PersonAssignment.find(params[:id])
    @assignable = @person_assignment.assignable
    @person = @assignable.person
    @assignee = @person_assignment.person
    @assignee_contact =  @assignee.contact
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
    @assignee = @person_assignment.person
    @assignee_contact =  @assignee.contact ||= @assignee.build_contact

    @person_assignment.attributes = person_assignment_params
    @assignee.attributes = assignee_params
    @assignee_contact.attributes = assignee_contact_params

    unless @person_assignment.save and @assignee.save and @assignee_contact.save
      flash[:danger] = error_message_for(@person_assignment, @assignee, @assignee_contact)
      redirect_to kapa_assignment_path(:id => @person_assignment) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_person_assignment_path(:id => @person_assignment)
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
    params.require(:person_assignment).permit(:assignable_id, :assignable_type, :type, :person_id, :sequence)
  end

  def assignee_params
    params.require(:assignee).permit(:id_number, :last_name, :middle_initial, :birth_date, :ssn, :ssn_agreement,
                                    :email, :first_name, :other_name, :title, :gender, :status)
  end

  def assignee_contact_params
    params.require(:assignee_contact).permit(:cur_phone, :mobile_phone, :email, :cur_street, :cur_city, :cur_state,
                                    :cur_postal_code, :per_street, :per_city, :per_state, :per_postal_code)
  end
end
