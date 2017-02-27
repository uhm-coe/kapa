module Kapa::UserSessionsControllerBase
  extend ActiveSupport::Concern

  included do
    skip_before_filter :check_if_route_is_enabled
    skip_before_filter :validate_login
    skip_before_filter :check_read_permission
    skip_before_filter :check_write_permission
    before_filter :validate_login, :only => :show
  end

  def new
    Kapa::UserSession.find.destroy if Kapa::UserSession.find
  end

  def show
  end

  def create
    session = Kapa::UserSession.new(user_session_params)
    unless session.save
      flash[:danger] = "Username/password do not match!"
      redirect_to :action => :new and return false
    end
    redirect_to kapa_root_path
  end

  def destroy
    flash[:info] = "You are successfully logged out."
    redirect_to :action => :new
  end

  def error
  end

  def user_session_params
    params.require(:user_session).permit(:uid, :password)
  end
end
