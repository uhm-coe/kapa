module Kapa::KapaControllerBase
  extend ActiveSupport::Concern

  included do
    layout "/kapa/layouts/kapa"
    protect_from_forgery
    before_action :sanitize_params
    before_action :check_if_route_is_enabled
    before_action :validate_login
    before_action :check_id_format, :only => :show
    before_action :check_read_permission
    before_action :check_write_permission, :only => [:new, :create, :update, :destroy, :import]
    after_action :remember_last_index, :only => :index
    after_action :put_timestamp
    helper :all
    helper_method :read?, :write?, :manage?, :access_all?, :access_dept?, :access_assigned?
  end

  def sanitize_params
    params.each_pair do |key1, value1|
      value1.each_pair do |key2, value2|
        #Remove blank elements on multi-select values
        params[key1][key2] = value2.delete_if {|v| v.blank?} if value2.is_a? Array
      end if value1.is_a?(ActionController::Parameters)
    end
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
    unless @current_user_session
      flash[:info] = "Please log in to continue."
      redirect_to(new_kapa_user_session_path) and return
    end

    @current_user = @current_user_session.user
    unless @current_user_session and @current_user
      flash[:info] = "Your session has expired! Please log in to continue."
      redirect_to(new_kapa_user_session_path) and return
    end

    unless @current_user.status >= 30
      flash[:danger] = "You are not authorized to use this system!  Please contact system administrator."
      redirect_to(new_kapa_user_session_path) and return
    end
    @current_user.request = request
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
    session[:last_index] = request.fullpath.gsub( /\?.*/, "" )
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

  def default_url_options(options={})
    if Rails.env.production?
      options.merge(:protocol => "https")
    else
      options
    end
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
      redirect_to(kapa_error_path) and return false
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

  def read?(name = controller_name)
    @current_user.check_permission(10, name)
  end

  def write?(name = controller_name)
    @current_user.check_permission(20, name)
  end

  def manage?(name = controller_name)
    @current_user.check_permission(30, name)
  end

  def access_all?(name = controller_name)
    @current_user.access_scope(name) >= 30
  end

  def access_dept?(name = controller_name)
    @current_user.access_scope(name) >= 20
  end

  def access_assigned?(name = controller_name)
    @current_user.access_scope(name) >= 10
  end

  def controller_name
    params[:controller].gsub("/", "_")
  end

  def filter(options = {})
    if Rails.configuration.try(:filter_save)
      @current_user.serialize(:filter, Rails.configuration.filter_defaults) if @current_user.deserialize(:filter).blank?
      @current_user.update_serialized_attributes(:filter, params.require(:filter).permit!) if params[:filter].present?
      @current_user.update_serialized_attributes(:filter, options) if options.present?
      @current_user.save
      filter = @current_user.deserialize(:filter, :as => OpenStruct)
    else
      session[:filter] = Rails.configuration.filter_defaults if session[:filter].nil?
      session[:filter].update(params.require(:filter).permit!) if params[:filter].present?
      session[:filter].update(options) if options.present?
      filter = OpenStruct.new(session[:filter])
    end  
    filter.user = @current_user
    return filter
  end
  
end
