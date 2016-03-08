module Kapa::CaseInvolvedPersonsControllerBase
  extend ActiveSupport::Concern

  def index
  end

  def show
    @case_involved_person = Kapa::CaseInvolvedPerson.find(params[:id])
    @case = @case_involved_person.case
    @person = @case.person
  end

  def new
  end

  def create
    @case_involved_person = Kapa::CaseInvolvedPerson.new(case_involved_person_params_subset(params))
    @case = Kapa::Case.find(params[:case_id])
    @case.case_involved_persons << @case_involved_person

    unless @case_involved_person.save
      flash[:danger] = error_message_for(@case_involved_person)
      redirect_to kapa_case_path(:id => @case) and return false
    end

    flash[:success] = "Person was successfully created."
    redirect_to kapa_case_path(:id => @case, :anchor => "involved_person")
  end

  def update
    @case_involved_person = Kapa::CaseInvolvedPerson.find(params[:id])
    @case = @case_involved_person.case_id
    @case_involved_person.attributes = case_involved_person_params_subset(params)

    unless @case_involved_person.save
      flash[:danger] = @case_involved_person.errors.full_messages.join(", ")
      redirect_to kapa_case_path(:id => @case) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_case_path(:id => @case, :anchor => "involved_person")
  end

  def destroy
    @case_involved_person = Kapa::CaseInvolvedPerson.find(params[:id])
    @case = @case_involved_person.case
    unless @case_involved_person.destroy
      flash[:danger] = error_message_for(@case_involved_person)
      redirect_to kapa_case_path(:id => @case) and return false
    end
    flash[:success] = "Person was successfully deleted."
    redirect_to kapa_case_path(:id => @case, :anchor => "involved_person")
  end

  def export
  end

  private
  def case_involved_person_params
    params.require(:case_involved_person).permit(:case_id, :type, :person_id, :last_name, :first_name, :middle_initial, :sequence, :yml, :xml)
  end

  # Only select and assign fields relevant to case_involved_person type. Unassigned fields will be nil.
  def case_involved_person_params_subset(params)
    case params[:case_involved_person][:type]
      when "internal"
        case_involved_person_params.slice("type", "person_id")
      when "external"
        case_involved_person_params.slice("type", "last_name", "first_name", "middle_initial")
    end
  end
end
