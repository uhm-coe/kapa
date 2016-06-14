module Kapa::CaseIncidentsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_incident = Kapa::CaseIncident.find(params[:id])
    @case_incident_ext = @case_incident.ext
    @case = @case_incident.case
    @case_involvements = @case.case_involvements
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @case_involvements = @case.case_involvements
    @case_incident = @case.case_incidents.build(:incident_occurred_at => DateTime.now)
  end

  def create
    @case = Kapa::Case.find(params[:case_id])
    @action = @case.case_incidents.build(case_incident_params)

    if @action.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @case, :anchor => "case_incidents")
  end

  def update
    @case_incident = Kapa::CaseIncident.find(params[:id])
    @case_incident.attributes = case_incident_params
    @case_incident.update_serialized_attributes(:_ext, case_incident_ext_params) if params[:case_incident_ext]

    if @case_incident.save
      flash[:success] = "Communication was successfully updated."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @case_incident.case_id, :anchor => params[:anchor], :action_panel => params[:action_panel])
  end

  def destroy
    @case_incident = Kapa::CaseIncident.find(params[:id])

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
