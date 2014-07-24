class Main::BaseController < ApplicationController
                
  def index
    validate_login if UserSession.find
  end

  def login
    reset_session
    if request.get?
      if params[:ticket]
        user = cas_validate(params[:ticket], login_url)
        unless user
          flash[:notice] = "Error during CAS authentication!"
          redirect_to :action => :index and return false
        end
        UserSession.create(user, true)
        redirect_to root_path
      else
        cas_login(login_url)
      end
    else
      session = UserSession.new(params[:user_session])
      unless session.save
        flash[:notice] = "Invalid user/password combination!"
        redirect_to :action => :index and return false
      end
      redirect_to root_path
    end
  end

  def logout
    UserSession.find.destroy if UserSession.find
    cas_logout root_url
  end

  def error
  end

  private
  def filter_defaults
    {:key => "Please enter key...",
     :academic_period => current_academic_period,
     :type => :admission}
  end
end
