module Kapa::CaseActionsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_action = Kapa::CaseAction.find(params[:id])
    @case_action_ext = @case_action.ext
    @case = @case_action.case
    @case_involvements = @case.case_involvements
    @documents = @case.documents
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
    @case_involvements = @case.case_involvements
    @case_involvements = @case.case_involvements
    @documents = []
    @documents += @case.files
    @documents += @case.forms
    @case_action = @case.case_actions.build(:action_date => Date.today)
  end

  def create
    @case = Kapa::Case.find(params[:case_id])
    @action = @case.case_actions.build(case_action_params)
#    @action.users << @current_user

    if @action.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @case, :anchor => "actions")
  end

  def update
    @action = Kapa::CaseAction.find(params[:id])
    @action.attributes = case_action_params
    @action.update_serialized_attributes(:_ext, case_action_ext_params) if params[:case_action_ext]

    if @action.save
      flash[:success] = "Action was successfully updated."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @action.case_id, :anchor => params[:anchor], :action_panel => params[:action_panel])
  end

  def destroy
    @action = Kapa::CaseAction.find(params[:id])

    if @action.destroy
      flash[:success] = "Action was successfully deleted."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @action.case, :anchor => params[:anchor])
  end

  private
  def case_action_params
    params.require(:case_action).permit(:action, :action_date, :action_specify, :case_id, :created_at, :id, :note, :person_id, :sequence, :type, :updated_at, :user_id, :user_ids => [])
  end

  def case_action_ext_params
    params.require(:case_action_ext).permit!
  end
end
