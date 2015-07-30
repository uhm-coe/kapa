module Kapa::Main::SessionsControllerBase
  extend ActiveSupport::Concern

  included do
    skip_before_filter :check_if_route_is_enabled
    skip_before_filter :validate_login
    skip_before_filter :check_read_permission
    skip_before_filter :check_write_permission
    skip_before_filter :check_manage_permission
    before_filter :validate_login, :only => :show
  end

  def new
  end

  def show
  end

  def create
    reset_session
    session = Kapa::UserSession.new(params[:user_session])
    unless session.save
      flash[:danger] = "Invalid user/password combination!"
      redirect_to kapa_root_path and return false
    end
    redirect_to kapa_root_path
  end

  def destroy
    Kapa::UserSession.find.destroy if Kapa::UserSession.find
    redirect_to kapa_root_path
  end

  def error
  end
end
