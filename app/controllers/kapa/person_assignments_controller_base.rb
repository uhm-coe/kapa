module Kapa::PersonAssignmentsControllerBase
  extend ActiveSupport::Concern

  def show
    @person_assignment = Kapa::PersonAssignment.find(params[:id])
    @assignable = @person_assignment.assignable
    @person = @assignable.person
  end

  def new
  end

  def create
    @person_assignment = Kapa::PersonAssignment.new(person_assignment_params)
    @assignable = Kapa::Case.find(params[:assignable_id])
    @assignable.person_assignments << @person_assignment

    unless @person_assignment.save
      flash[:danger] = error_message_for(@person_assignment)
      redirect_to kapa_case_path(:id => @assignable) and return false
    end

    flash[:success] = "Person was successfully created."
    redirect_to kapa_case_path(:id => @assignable, :anchor => "involved_person")
  end

  def update
    @person_assignment = Kapa::PersonAssignment.find(params[:id])
    @assignable = @person_assignment.assignable_id
    @person_assignment.attributes = person_assignment_params

    unless @person_assignment.save
      flash[:danger] = @person_assignment.errors.full_messages.join(", ")
      redirect_to kapa_assignable_path(:id => @assignable) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_assignable_path(:id => @assignable, :anchor => "involved_person")
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
    params.require(:person_assignment).permit(:assignable_id, :type, :person_id, :sequence, :yml, :xml)
  end

  # Only select and assign fields relevant to person_assignment type. Unassigned fields will be nil.
  #def person_assignment_params_subset(params)
  #  assignable params[:person_assignment][:type]
  #    when "internal"
  #      person_assignment_params.slice("type", "person_id")
  #    when "external"
  #      person_assignment_params.slice("type", "last_name", "first_name", "middle_initial")
  #  end
  #end
end
