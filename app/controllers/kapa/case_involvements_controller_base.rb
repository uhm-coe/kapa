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
    params.require(:case_involvement).permit(:affiliation, :bargaining_unit, :case_id, :category, :created_at, :id, :job_title, :note, :person_id, :sequence, :status, :type, :updated_at)
  end

  def person_params
    params.require(:person).permit(:birth_date, :business_phone, :created_at, :cur_city, :cur_phone, :cur_postal_code, :cur_state, :cur_street, :dept, :email, :email_alt, :ethnicity, :ets_id, :fax, :first_name, :gender, :id, :id_number, :last_name, :middle_initial, :mobile_phone, :note, :other_name, :per_city, :per_phone, :per_postal_code, :per_state, :per_street, :source, :ssn, :ssn_agreement, :ssn_crypted, :status, :title, :type, :uid, :updated_at)
  end
end
