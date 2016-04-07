module Kapa::CaseActionsControllerBase
  extend ActiveSupport::Concern

  def show
    @case_action = Kapa::CaseAction.find(params[:id])
    @case = @case_action.case
  end

  def new
    @case = Kapa::Case.find(params[:case_id])
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
    params.require(:case_action).permit(:action_date, :action, :action_specify, :note, :user_ids => [])
  end
end
