module Kapa::KapaControllerBase
  extend ActiveSupport::Concern

  included do
    layout "/kapa/layouts/kapa"
    protect_from_forgery
    before_filter :check_if_route_is_enabled
    before_filter :validate_login
    before_filter :check_id_format, :only => :show
    before_filter :check_read_permission
    before_filter :check_write_permission, :only => [:new, :create, :update, :destroy, :import]
    after_filter :put_timestamp
    after_filter :remember_last_index, :only => :index
    helper :all
  end

  def check_if_route_is_enabled
    unless Rails.configuration.available_routes.include?(controller_name)
      flash[:danger] = "#{controller_name} is not available."
      redirect_to(kapa_error_path) and return false
    end
  end

  def check_id_format
    if params[:id].to_s.match(/^[0-9]+$/)
      flash[:danger] = "Invalid ID format."
      redirect_to(kapa_error_path) and return false
    end
  end

  def validate_login
    @current_user_session = Kapa::UserSession.find
    if @current_user_session
      @current_user = @current_user_session.user
      @current_user.request = request
    else
      flash[:info] = "Please log in to continue."
      redirect_to(new_kapa_user_session_path) and return
    end
    unless @current_user_session and @current_user and @current_user.status >= 30
      @current_user_session.destroy if @current_user_session
      flash[:danger] = "You are not authorized to use this system!  Please contact system administrator."
      redirect_to(new_kapa_user_session_path) and return
    end
  end

  def check_read_permission
    unless @current_user.read?(controller_name)
      flash[:danger] = "You do not have a read permission on #{controller_name}."
      redirect_to(kapa_error_path) and return false
    end
  end

  def check_write_permission
    unless @current_user.write?(controller_name)
      flash[:danger] = "You do not have a write permission on #{controller_name}."
      redirect_to(kapa_error_path) and return false
    end
  end

  def remember_last_index
    session[:last_index] = request.fullpath
  end

  def put_timestamp
    user = @current_user ? @current_user : @current_student_user
    if user
      user.request = request if user.request.nil?
      user.put_timestamp
    end
  end

  def redirect_to(options = {}, response_status = {})
    if request.xhr?
      render(:js => "window.location.href = '#{url_for(options)}'")
    else
      super(options, response_status)
    end
  end

  def render_notice(options = {:effect => "highlight"})
    script = ""
    [:notice1, :notice2, :notice3].each do |i|
      script << "jQuery('##{i}').html('#{flash[i].gsub("'", "\\\\'")} (#{DateTime.now.strftime("%H:%M:%S")})').effect('#{options[:effect]}');\n" if not flash[i].blank?
    end
    render(:js => script)
  end

  protected
  #  def local_request?
  #    false
  #  end

  def rescue_action_in_public(exception)
    if request.xhr?
      flash[:danger] = "We are sorry, but something went wrong."
      render_notice and return false
    else
      flash[:danger] = "We are sorry, but something went wrong."
      redirect_to(Rails.configuration.routing_mode == "student" ? student_kapa_error_path : kapa_error_path) and return false
    end
  end

  private
  def error_message_for(*args)
    options = args.last.is_a?(Hash) ? args.last : {}
    errors = []
    args.each { |a| errors << a.errors.full_messages.join(", ") if a.is_a?(ActiveRecord::Base) and not a.errors.blank? }
    message = errors.join(", ")
    options[:sub].each_pair { |pattern, replacement| message.gsub!(pattern, replacement) } if options[:sub]
    return message
  end

  def controller_name
    params[:controller].gsub("/", "_")
  end

  def filter(options = {})
    name = :filter
    session[name] = filter_defaults if session[name].nil?
    session[name].update(params[:filter]) if params[:filter].present?
    session[name].update(options) if options.present?
    filter = OpenStruct.new(session[name])
    filter.user = @current_user
    return filter
  end

  def filter_defaults
    {:key => "",
     :active => 1,
     :property => :major,
     :date_start => Date.today,
     :date_end => Date.today,
     :term_id => Kapa::Term.current_term.id,
     :start_term_id => Kapa::Term.current_term.id,
     :end_term_id => Kapa::Term.current_term.id,
     :per_page => Rails.configuration.items_per_page}
  end
end
