module Kapa::Main::Concerns::BaseController
  extend ActiveSupport::Concern

  def welcome
    validate_login if UserSession.find
  end

  def login
    reset_session
    session = UserSession.new(params[:user_session])
    unless session.save
      flash[:danger] = "Invalid user/password combination!"
      redirect_to kapa_root_path and return false
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
     :type => :admission,
     :per_page => Rails.configuration.items_per_page}
  end
end
