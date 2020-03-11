module Kapa::NotificationsControllerBase
  extend ActiveSupport::Concern
  def index
    @notifications = @current_user.notifications.order(:created_at => :desc)
    @person = @current_user.person
  end

  def show
    @notification = Kapa::Notification.find(params[:id])

    unless @notification.user == @current_user
      redirect_to :action => :index and return false
    end

    @notification_ext = @notification.ext
    @person = @current_user.person
    @notification.mark_as_read!
  end

  def dismiss
    @notification = Kapa::Notification.find(params[:id])
    @notification.mark_as_read!
    redirect_to params[:return_path]
  end

  def destroy
    @notification = Kapa::Notification.find(params[:id])

    if @notification.destroy
      flash[:notice] = "Notification was successfully deleted."
    else
      flash[:alert] = error_message_for @notification
    end
    redirect_to kapa_notifications_path(:action => :index)
  end
end
