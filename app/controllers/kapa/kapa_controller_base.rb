module Kapa::KapaControllerBase
  extend ActiveSupport::Concern

  included do
    layout "kapa/layouts/kapa"
    protect_from_forgery
    before_action :sanitize_params
    before_action :validate_url
    before_action :validate_user
    before_action :validate_permission
    after_action :put_timestamp
    helper :all
    helper_method :read?, :update?, :create?, :destroy?, :import?, :export?, :summarize?, :manage?, :access_all?, :access_dept?, :access_assigned?
  end

  def sanitize_params
    params.each_pair do |key1, value1|
      value1.each_pair do |key2, value2|
        #Remove blank elements on multi-select values
        params[key1][key2] = value2.delete_if {|v| v.blank?} if value2.is_a? Array
      end if value1.is_a?(ActionController::Parameters)
    end
  end

  def validate_url
    unless Rails.configuration.available_routes.include?(controller_name.to_s)
      flash[:alert] = "#{controller_name} is not available."
      redirect_to(kapa_error_path) and return false
    end

    if params[:action] == "show"  and params[:id].to_s.match(/^[0-9]+$/)
      flash[:alert] = "Invalid ID format."
      redirect_to(kapa_error_path) and return false
    end
  end

  def validate_user
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
      flash[:alert] = "You are not authorized to use this system!  Please contact system administrator."
      redirect_to(new_kapa_user_session_path) and return
    end
  end

  def validate_permission
    case params[:action]
    when "show", "index"
      permission = :read?
    when "update"
      permission = :update?
    when "new", "create"
      permission = :create?
    when "destroy"
      permission = :destroy?
    when "import"
      permission = :import?
    when "export"
      permission = :export?
    when "summarize"
      permission = :summarize?
    end

    if permission and not self.send(permission)
      flash[:alert] = "You do not have a #{permission.to_s.gsub("?", "")} permission on #{controller_name}."
      redirect_to(kapa_error_path) and return false
    end
  end

  def put_timestamp
    @current_user.user_timestamps.create(:method => request.method,
                                         :path => request.path,
                                         :remote_ip => request.remote_ip,
                                         :agent => request.env['HTTP_USER_AGENT'].downcase) if @current_user
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
  def rescue_action_in_public(exception)
    flash[:alert] = t(:kapa_error_message_default)
    if request.xhr?
      render_notice and return false
    else
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

  def controller_name
    @controller_name = params[:controller].gsub("/", "_").to_sym if @controller_name.nil?
    return @controller_name
  end

  def read?(name = controller_name)
    @current_user.check_permission(name, "R")
  end

  def update?(name = controller_name)
    @current_user.check_permission(name, "U")
  end

  def create?(name = controller_name)
    @current_user.check_permission(name, "C")
  end

  def destroy?(name = controller_name)
    @current_user.check_permission(name, "D")
  end

  def export?(name = controller_name)
    @current_user.check_permission(name, "E")
  end

  def import?(name = controller_name)
    @current_user.check_permission(name, "I")
  end

  def summarize?(name = controller_name)
    @current_user.check_permission(name, "S")
  end

  def manage?(name = controller_name)
    @current_user.check_permission(name, "M")
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
