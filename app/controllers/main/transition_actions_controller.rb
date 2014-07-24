class Main::TransitionActionsController < Main::BaseController

  def create
    @transition_point = TransitionPoint.find(params[:id])
    @action = @transition_point.transition_actions.build(params[:transition_action])
    unless @action.save
      flash.now[:notice2] = error_message_for @action
      render_notice and return false
    end
    flash[:notice2] = "Action was successfully created."
    redirect_to main_transition_points_path(:action => :show, :id => @transition_point, :focus => params[:focus])
  end

  def update
    @action = TransitionAction.find(params[:id])
    @action.attributes= params[:transition_action][@action.id.to_s]
    unless @action.save
      flash.now[:notice2] = error_message_for @action
      render_notice and return false
    end
    flash[:notice2] = "Action was successfully updated."
    render_notice
  end

  def destroy
    @action = TransitionAction.find(params[:id])
    unless @action.destroy
      flash.now[:notice2] = error_message_for @action
      render_notice and return false
    end
    flash[:notice2] = "Action was successfully deleted."
    redirect_to main_transition_points_path(:action => :show, :id => @action.transition_point, :focus => params[:focus])
  end
end
