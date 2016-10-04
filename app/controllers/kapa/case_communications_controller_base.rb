module Kapa::CaseCommunicationsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_communication = Kapa::CaseCommunication.find(params[:id])
    @case_communication_ext = @case_communication.ext
    @case = @case_communication.case
    @case_involvements = @case.case_involvements
    @documents = []
    @documents += @case.files
    @documents += @case.forms
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @case_involvements = @case.case_involvements
    @case_involvements = @case.case_involvements
    @documents = []
    @documents += @case.files
    @documents += @case.forms
    @case_communication = @case.case_communications.build(:contacted_at => DateTime.now)
  end

  def create
    @case = Kapa::Case.find(params[:case_id])
    @action = @case.case_communications.build(case_communication_params)

    if @action.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @case, :anchor => "communications")
  end

  def update
    @action = Kapa::CaseCommunication.find(params[:id])
    @action.attributes = case_communication_params
    @action.update_serialized_attributes(:_ext, case_communication_ext_params) if params[:case_communication_ext]

    if @action.save
      flash[:success] = "Communication was successfully updated."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @action.case, :anchor => params[:anchor])
  end

  def destroy
    @action = Kapa::CaseCommunication.find(params[:id])

    if @action.destroy
      flash[:success] = "Communication was successfully deleted."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @action.case, :anchor => params[:anchor])
  end

  private
  def case_communication_params
    params.require(:case_communication).permit(:case_id, :category, :contacted_at, :created_at, :id, :note, :person_id, :sequence, :user_id, :status, :type, :updated_at)
  end

  def case_communication_ext_params
    params.require(:case_communication_ext).permit!
  end
end
