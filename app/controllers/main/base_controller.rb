class Main::BaseController < ApplicationBaseController


  def index
    validate_login if UserSession.find
  end

  def login
    reset_session
    session = UserSession.new(params[:user_session])
    unless session.save
      flash[:notice] = "Invalid user/password combination!"
      redirect_to :action => :index and return false
    end
    redirect_to root_path
  end

  def logout
    UserSession.find.destroy if UserSession.find
    redirect_to root_path
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
