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
    @unverified = true
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

    unless @case_involvement.save and @case.save
      flash[:danger] = error_message_for(@case_involvement)
      redirect_to kapa_case_path(:id => @case, :anchor => "case_involvements") and return false
    end

    flash[:success] = "Person was successfully added."
    redirect_to kapa_case_involvement_path(:id => @case_involvement)
  end

  def update
    @case_involvement = Kapa::CaseInvolvement.find(params[:id])
    @case = @case_involvement.case

    @case_involvement.attributes = case_involvement_params
    unless @case_involvement.save and @case.save
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
    params.require(:case_involvement).permit(:case_id, :type, :affiliation, :bargaining_unit, :job_title, :person_id, :note, :sequence)
  end
end
