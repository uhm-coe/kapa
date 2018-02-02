module Kapa::UserSessionsControllerBase
  extend ActiveSupport::Concern

  included do
    skip_before_action :check_if_route_is_enabled
    skip_before_action :validate_login
    skip_before_action :check_read_permission
    skip_before_action :check_write_permission
    before_action :validate_login, :only => :show
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
    success
    redirect_to kapa_root_path
  end

  def destroy
    flash[:info] = "You are successfully logged out."
    if Kapa::Cas.defined?
      redirect_to Kapa::Cas.logout_url(new_kapa_user_session_url) and return
    else
      redirect_to :action => :new and return
    end
  end

  def cas
    if Kapa::Cas.defined?
      redirect_to Kapa::Cas.login_url(kapa_user_session_validate_url) and return
    else
      flash[:alert] = "CAS configration error"
      redirect_to :action => :new and return
    end
  end

  def validate
    unless Kapa::Cas.defined? and params[:ticket]
      flash[:alert] = "Error during CAS authentication (CAS configration error)."
      redirect_to :action => :new and return false
    end

    @cas_results = Kapa::Cas.validate(params[:ticket], kapa_user_session_validate_url)
    if @cas_results[0] == "yes"
      uid = @cas_results[1]
      register(uid)
      user = Kapa::User.find_by(:uid => uid, :category => "ldap", :status => 30)
      if user
        Kapa::UserSession.create(user, true)
        success
        redirect_to(:action => :show)
      else
        flash[:alert] = "#{uid} is not an authorized user."
        redirect_to(:action => :new) and return false
      end
    else
      flash[:alert] = "Error during CAS authentication (Unable to validate the ticket)."
      redirect_to(:action => :new) and return false
    end
  end

  def error
  end

  def success
  end

  private
  def register(uid)
    #Implement this method for auto user registration
  end

  def user_session_params
    params.require(:user_session).permit(:uid, :password)
  end
end
