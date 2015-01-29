class Kapa::Main::BaseController < Kapa::KapaBaseController

  def welcome
    validate_login if UserSession.find
  end

  def login
    reset_session
    session = UserSession.new(params[:user_session])
    unless session.save
      flash[:danger] = "Invalid user/password combination!"
      redirect_to :action => :index and return false
    end
    redirect_to kapa_root_path
  end

  def logout
    UserSession.find.destroy if UserSession.find
    redirect_to kapa_root_path
  end

  def error
  end

  private
  def filter_defaults
    {:key => "",
     :term_id => Term.current_term.id,
     :type => :admission}
  end
end
