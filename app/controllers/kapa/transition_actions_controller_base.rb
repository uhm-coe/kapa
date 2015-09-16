module Kapa::TransitionActionsControllerBase
  extend ActiveSupport::Concern

  def create
    @transition_point = Kapa::TransitionPoint.find(params[:id])
    @action = @transition_point.transition_actions.build(create_transition_action_params)

    if @action.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_transition_point_path(:id => @transition_point, :anchor => params[:anchor], :action_panel => @action.id)
  end

  def update
    @action = Kapa::TransitionAction.find(params[:id])
    @action.attributes = update_transition_action_params(@action.id.to_s)

    if @action.save
      flash[:success] = "Action was successfully updated."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_transition_point_path(:id => @action.transition_point_id, :anchor => params[:anchor], :action_panel => params[:action_panel])
  end

  def destroy
    @action = Kapa::TransitionAction.find(params[:id])

    if @action.destroy
      flash[:success] = "Action was successfully deleted."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_transition_point_path(:id => @action.transition_point, :anchor => params[:anchor])
  end

  private
  def transition_action_fields
    [:action_date, :action, :action_specify, :user_id, :note]
  end
  def create_transition_action_params
    params.require(:transition_action).permit(*transition_action_fields)
  end
  def update_transition_action_params(action_id)
    params.require(:transition_action)[action_id].permit(*transition_action_fields)
  end
end
