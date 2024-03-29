module Kapa::UserSessionsControllerBase
  extend ActiveSupport::Concern

  included do
    skip_before_action :validate_url
    skip_before_action :validate_user
    skip_before_action :validate_permission
    before_action :validate_user, :only => [:show, :destroy]
  end
  
  def new
    # flash_clone = flash.clone
    # Kapa::UserSession.find.try(:destroy)
    # reset_session

    # #Restore flash messages
    # flash_clone.keys.each do |key|
    #   flash[key] = flash_clone[key]
    # end
  end

  def show
  end

  def create
    session = Kapa::UserSession.new(user_session_params.to_h)
    unless session.save
      flash[:alert] = "Username/password do not match!"
      redirect_to new_kapa_user_session_path and return
    end
    flash[:alert] = nil
    success
    redirect_to kapa_root_path
  end

  def destroy
    @current_user.serialize!(:filter, {}) if Rails.configuration.try(:filter_save)
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
      user = Kapa::User.find_by("uid = ? and category = ? and status >= ?", uid, "ldap", 30)
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

  def success
    flash.clear
  end

  def error
  end

  private
  def register(uid)
    #Implement this method for auto user registration
  end

  def user_session_params
    params.require(:user_session).permit(:uid, :password)
  end
end
