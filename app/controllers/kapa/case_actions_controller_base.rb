module Kapa::CaseActionsControllerBase
  extend ActiveSupport::Concern

  def create
    @case = Kapa::Case.find(params[:id])
    @action = @case.case_actions.build(create_case_action_params)

    if @action.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_case_path(:id => @case, :anchor => params[:anchor], :action_panel => @action.id)
  end

  def update
    @action = Kapa::CaseAction.find(params[:id])
    @action.attributes = update_case_action_params(@action.id.to_s)

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
  def case_action_fields
    [:action_date, :action, :action_specify, :user_id, :note]
  end
  def create_case_action_params
    params.require(:case_action).permit(*case_action_fields)
  end
  def update_case_action_params(action_id)
    params.require(:case_action)[action_id].permit(*case_action_fields)
  end
end
