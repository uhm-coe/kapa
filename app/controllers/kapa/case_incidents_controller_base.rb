module Kapa::CaseIncidentsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_incident = Kapa::CaseIncident.find(params[:id])
    @case_incident_ext = @case_incident.ext
    @case_violations = @case_incident.case_violations
    @case = @case_incident.case
    @case_involvements = @case.case_involvements
    @documents = @case.documents
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @case_involvements = @case.case_involvements
    @case_incident = @case.case_incidents.build(:incident_occurred_at => DateTime.now)
  end

  def create
    @case = Kapa::Case.find(params[:case_id])
    @case_incudent = @case.case_incidents.build(case_incident_params)

    if @case_incudent.save
      flash[:success] = "Incident was successfully created."
    else
      flash[:danger] = error_message_for @case_incudent
    end
    redirect_to kapa_case_incident_path(:id => @case_incudent)
  end

  def update
    @case_incident = Kapa::CaseIncident.find(params[:id])
    @case_incident.attributes = case_incident_params
    @case_incident.update_serialized_attributes(:_ext, case_incident_ext_params) if params[:case_incident_ext]

    if @case_incident.save
      flash[:success] = "Incident was successfully updated."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @case_incident.case_id, :anchor => params[:anchor], :action_panel => params[:action_panel])
  end

  def destroy
    @case_incident = Kapa::CaseIncident.find(params[:id])
    @case_incident.case_violations.clear
    if @case_incident.destroy
      flash[:success] = "Incident was successfully deleted."
    else
      flash[:danger] = error_message_for @case_incident
    end
    redirect_to kapa_case_path(:id => @case_incident.case, :anchor => params[:anchor])
  end

  private
  def case_incident_params
    params.require(:case_incident).permit(:activities, :case_id, :incident_occurred_at, :location, :location_detail, :note, :status_updated_at, :type, :violations)
  end

  def case_incident_ext_params
    params.require(:case_incident_ext).permit!
  end
end
