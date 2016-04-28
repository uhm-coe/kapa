module Kapa::CaseInvolvementsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_involvement = Kapa::CaseInvolvement.find(params[:id])
    @case_involvement_ext = @case_involvement.ext
    @case = @case_involvement.case
    @person = @case_involvement.person
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @person = Kapa::Person.new :source => "Manual"
  end

  def create
    @case = Kapa::Case.find(params[:case_id])
    @case_involvement = @case.case_involvements.build(case_involvement_params)
    if params[:person]
      @person = Kapa::Person.new(person_params)
      unless @person.save and @case_involvement.save
        flash[:danger] = error_message_for(@person)
        redirect_to kapa_case_path(:id => @case, :anchor => "case_involvements") and return false
      end
      @case_involvement.person = @person
    end

    unless @case_involvement.save
      flash[:danger] = error_message_for(@case_involvement)
      redirect_to kapa_case_path(:id => @case, :anchor => "case_involvements") and return false
    end

    flash[:success] = "Person was successfully added."
    redirect_to kapa_case_involvement_path(:id => @case_involvement)
  end

  def update
    @case_involvement = Kapa::CaseInvolvement.find(params[:id])
    @case = @case_involvement.case

    @person = @case_involvement.person
    @person.attributes = person_params if params[:person]
    @person.attributes = contact_params if params[:contact]
    unless @person.save
      flash[:danger] = error_message_for(@person)
      redirect_to kapa_case_involvement_path(:id => @case_involvement) and return false
    end

    @case_involvement.attributes = case_involvement_params
    unless @case_involvement.save
      flash[:danger] = error_message_for(@case_involvement)
      redirect_to kapa_case_involvement_path(:id => @case_involvement) and return false
    end

    flash[:success] = "Person was successfully updated."
    redirect_to kapa_case_path(:id => @case, :anchor => "case_involvements")
  end

  def destroy
    @case_involvement = Kapa::CaseInvolvement.find(params[:id])
    @case = @case_involvement.case
    unless @case_involvement.destroy
      flash[:danger] = error_message_for(@case_involvement)
      redirect_to kapa_case_path(:id => @case, :anchor => "case_involvements") and return false
    end
    flash[:success] = "Person was successfully deleted."
    redirect_to kapa_case_path(:id => @case, :anchor => "case_involvements")
  end

  private
  def case_involvement_params
    params.require(:case_involvement).permit(:case_id, :type, :person_id, :note, :sequence)
  end

  def person_params
    params.require(:person).permit(:id_number, :last_name, :middle_initial, :birth_date, :ssn, :ssn_agreement,
                                    :email, :first_name, :other_name, :title, :gender, :status)
  end

  def contact_params
    params.require(:contact).permit(:entity_id, :entity_type, :cur_phone, :mobile_phone, :email, :cur_street, :cur_city, :cur_state,
                                    :cur_postal_code, :per_street, :per_city, :per_state, :per_postal_code)
  end
end
