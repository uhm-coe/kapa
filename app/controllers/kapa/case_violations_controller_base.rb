module Kapa::CaseViolationsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_violation = Kapa::CaseViolation.find(params[:id])
    @case_violation_ext = @case_violation.ext
    @case_incident = @case_violation.case_incident
    @case = @case_incident.case
    @case_involvements = @case.case_involvements
  end

  def new
    @case_incident = Kapa::CaseIncident.find(params[:case_incident_id])
    @case = @case_incident.case
    @case_involvements = @case.case_involvements
  end

  def create
    @case_incident = Kapa::CaseIncident.find(params[:case_incident_id])
    @case_violation = @case_incident.case_violations.build(case_violation_params)

    unless @case_violation.save
      flash[:danger] = error_message_for @case_violation
      redirect_to kapa_case_incident_path(:id => @case_incident, :anchor => "case_violations") and return
    end
    redirect_to kapa_case_incident_path(:id => @case_incident, :anchor => "case_violations")
  end

  def update
    @case_violation = Kapa::CaseViolation.find(params[:id])
    @case_violation.attributes = case_violation_params
    @case_violation.update_serialized_attributes(:_ext, case_violation_ext_params) if params[:case_violation_ext]

    if @case_violation.save
      flash[:success] = "Poilicy violation was successfully updated."
    else
      flash[:danger] = error_message_for @case_violation
    end
    redirect_to kapa_case_incident_path(:id => @case_violation.case_incident_id, :anchor => params[:anchor])
  end

  def destroy
    @case_violation = Kapa::CaseViolation.find(params[:id])
    if @case_violation.destroy
      flash[:success] = "Poilicy violation was successfully deleted."
    else
      flash[:danger] = error_message_for @case_violation
    end
    redirect_to kapa_case_incident_path(:id => @case_violation.case_incident, :anchor => params[:anchor])
  end

  private
  def case_violation_params
    params.require(:case_violation).permit(:case_incident_id, :case_involvement_id, :created_at, :id, :note, :policy, :type, :updated_at)
  end

  def case_violation_ext_params
    params.require(:case_violation_ext).permit!
  end
end
