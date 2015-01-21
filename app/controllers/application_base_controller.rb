# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationBaseController < ActionController::Base
  layout "kapa"
  protect_from_forgery
  before_filter :validate_login, :except => [:welcome, :login, :logout, :error]
  before_filter :check_read_permission, :except => [:welcome, :login, :logout, :error]
  before_filter :check_write_permission, :only => [:new, :create, :update]
  before_filter :check_manage_permission, :only => [:destroy, :export, :import, :search]
  after_filter :put_timestamp
  helper :all
  # TODO: Need to remove :current_academic_period and :next_academic_period later
  helper_method :url_for, :module_name, :current_academic_period, :next_academic_period, :menu_items

  def validate_login
    @current_user_session = UserSession.find
    @current_user = @current_user_session.user if @current_user_session
    @current_user.request = request
    unless @current_user_session and @current_user and @current_user.status >= 3 and @current_user.emp_status >= 1
      @current_user_session.destroy if @current_user_session
      flash[:danger] = "You are not authorized to use this system!  Please contact system administrator."
      redirect_to(root_url) and return
    end
  end

  def check_read_permission
    unless @current_user.read?(module_name)
      flash[:danger] = "You do not have a permission to read on the #{module_name} module."
      redirect_to(error_path) and return false
    end
  end

  def check_write_permission
    unless @current_user.write?(module_name, :delegate => params[:action])
      flash[:danger] = "You do not have a permission to write records on the #{module_name} module."
      redirect_to(error_path) and return false
    end
  end

  def check_manage_permission
    unless @current_user.write?(module_name, :delegate => params[:action])
      flash[:danger] = "You do not have a permission to manage records on the #{module_name} module."
      redirect_to(error_path) and return false
    end
  end

  def put_timestamp
    user = @current_user ? @current_user : @current_student_user
    if user
      user.request = request if user.request.nil?
      user.put_timestamp
    end
  end

  #def url_for(options = {})
  #  if options.kind_of?(Hash)
  #    #This will avoid generating absolute path when hash is passed in.
  #    options[:only_path] = true if options[:controller].blank?
  #
  #    if validate_authkey?(options[:action])
  #      id = options[:id].kind_of?(ActiveRecord::Base) ? options[:id].id.to_s : options[:id].to_s
  #      options[:authkey] = authkey(id)
  #    end
  #  end
  #  super(options)
  #end

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
      redirect_to(Rails.configuration.routing_mode == "student" ? student_error_path : error_path) and return false
    end
  end

  private
  def error_message_for(*args)
    options =  args.last.is_a?(Hash) ? args.last : {}
    errors = []
    args.each {|a| errors << a.errors.full_messages.join(", ") if a.is_a?(ActiveRecord::Base) and not a.errors.blank?}
    message = errors.join(", ")
    options[:sub].each_pair { |pattern, replacement| message.gsub!(pattern, replacement) } if options[:sub]
    return message
  end

  def module_name
    params[:controller].split("/").first
  end

  def filter(options = {})
    name = "filter_#{module_name}".to_sym
    f_hash = session[name] ||= HashWithIndifferentAccess.new(filter_defaults)
    f_hash.update(params[:filter]) if params[:filter].present?
    f_hash.update(options) if options.present?
    return ApplicationFilter.new(f_hash)
  end

  def filter_defaults
    {}
  end

  # TODO: Implement this method using start date and end date, copy from Term model
  def current_term
    return Term.find_by_code("201530")
  end

  # TODO: Delete later
  def current_academic_period
    today = Date.today
    if today.month >= 1 and today.month < 6
      return "#{today.year}30"
    elsif today.month >= 6 and today.month < 8
      return "#{today.year}40"
    elsif today.month >= 8 and today.month <= 12
      return "#{today.year + 1}10"
    end
  end

  # TODO: Delete later
  def next_academic_period
    value = ApplicationProperty.where("code > ?", current_academic_period).order("code").first
    return value.code
  end

  def menu_items(name, options = {})
    items = []
    case name.to_s
    when "main"
      items.push ["Search Person", main_persons_path]  if @current_user.manage?(:main, :delegate => :search)
      items.push ["Program Cohorts", main_curriculums_path]  if @current_user.read? (:main)
      items.push ["Transition Points", main_transition_points_path] if @current_user.read?(:main)
    when "artifact"
      items.push ["Forms", artifact_forms_path] if @current_user.manage?(:artifact, :delegate => :form)
      items.push ["Test Scores", artifact_exams_path] if @current_user.manage?(:artifact, :delegate => :exam)
    when "advising"
      items.push ["Sessions", advising_sessions_path]  if @current_user.read?(:advising)
    when "course"
      items.push ["Rosters", course_rosters_path] if @current_user.read?(:course)
    when "practicum"
      items.push ["Placement Audits", practicum_placements_path]  if @current_user.read?(:practicum)
      items.push ["Mentor Assignments", practicum_assignments_path]  if @current_user.read?(:practicum)
      items.push ["Schools", practicum_schools_path]  if @current_user.read?(:practicum)
    when "admin"
      items.push ["Terms", admin_terms_path] if @current_user.manage?(:admin, :delegate => :term)
      items.push ["Programs", admin_programs_path]  if @current_user.manage?(:admin, :delegate => :program)
      items.push ["Assessments", admin_rubrics_path]  if @current_user.manage?(:admin, :delegate => :rubric)
      items.push ["User Accounts", admin_users_path]  if @current_user.manage?(:admin, :delegate => :user)
#      items.push ["User Activities", admin_users_path(:action => :logs)]   if @current_user.manage?(:admin, :delegate => :user)
      items.push ["System Properties", admin_properties_path]   if @current_user.manage?(:admin)
    end
    items
  end

  #This method returns nil if it encounter any nil object during reflection.
  def rsend(object, *args, &block)
    obj = object
    args.each do |a|
      b = (a.is_a?(Array) && a.last.is_a?(Proc) ? a.pop : block)
      obj = obj.__send__(*a, &b) if obj
    end
    obj
  end
end
