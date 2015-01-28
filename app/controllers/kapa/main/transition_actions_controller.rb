class Kapa::Main::TransitionActionsController < Kapa::Main::BaseController

  def create
    @transition_point = TransitionPoint.find(params[:id])
    @action = @transition_point.transition_actions.build(params[:transition_action])

    if @action.save
      flash[:success] = "Action was successfully created."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_main_transition_point_path(:id => @transition_point, :focus => params[:focus], :action_panel => @action.id)
  end

  def update
    @action = TransitionAction.find(params[:id])
    @action.attributes = params[:transition_action][@action.id.to_s]

    if @action.save
      flash[:success] = "Action was successfully updated."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_main_transition_point_path(:id => @action.transition_point_id, :focus => params[:focus], :action_panel => params[:action_panel])
  end

  def destroy
    @action = TransitionAction.find(params[:id])

    if @action.destroy
      flash[:success] = "Action was successfully deleted."
    else
      flash[:danger] = error_message_for @action
    end
    redirect_to kapa_main_transition_point_path(:id => @action.transition_point, :focus => params[:focus])
  end
end
