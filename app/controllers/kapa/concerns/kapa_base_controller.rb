module Kapa::Concerns::KapaBaseController
  extend ActiveSupport::Concern

  included do
    layout "/kapa/layouts/kapa"
    protect_from_forgery
    before_filter :validate_login, :except => [:welcome, :login, :logout, :error]
    before_filter :check_read_permission, :except => [:welcome, :login, :logout, :error]
    before_filter :check_write_permission, :only => [:new, :create, :update]
    before_filter :check_manage_permission, :only => [:destroy, :export, :import, :search]
    after_filter :put_timestamp
    helper :all
    helper_method :url_for, :module_name, :menu_items
  end # included

  def validate_login
    @current_user_session = Kapa::UserSession.find
    @current_user = @current_user_session.user if @current_user_session
    @current_user.request = request
    unless @current_user_session and @current_user and @current_user.status >= 3
      @current_user_session.destroy if @current_user_session
      flash[:danger] = "You are not authorized to use this system!  Please contact system administrator."
      redirect_to(kapa_root_url) and return
    end
  end

  def check_read_permission
    unless @current_user.read?(module_name)
      flash[:danger] = "You do not have a permission to read on the #{module_name} module."
      redirect_to(kapa_error_path) and return false
    end
  end

  def check_write_permission
    unless @current_user.write?(module_name, :delegate => params[:action])
      flash[:danger] = "You do not have a permission to write records on the #{module_name} module."
      redirect_to(kapa_error_path) and return false
    end
  end

  def check_manage_permission
    unless @current_user.write?(module_name, :delegate => params[:action])
      flash[:danger] = "You do not have a permission to manage records on the #{module_name} module."
      redirect_to(kapa_error_path) and return false
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

  def module_name
    params[:controller].split("/").second
  end

  def filter(options = {})
    name = "filter_#{module_name}".to_sym
    session[name] = filter_defaults if session[name].nil?
    session[name].update(params[:filter]) if params[:filter].present?
    session[name].update(options) if options.present?
    filter = OpenStruct.new(session[name])
    filter.user = @current_user
    return filter
  end

  def filter_defaults
    {}
  end

  def menu_items(name, options = {})
    items = []
    case name.to_s
      when "main"
        items.push ["Search Person", kapa_main_persons_path] if @current_user.manage?(:main, :delegate => :search)
        items.push ["Cohorts", kapa_main_curriculums_path] if @current_user.read? (:main)
        items.push ["Transition Points", kapa_main_transition_points_path] if @current_user.read?(:main)
        items.push ["Enrollments", kapa_main_enrollments_path] if @current_user.read?(:main)
      when "document"
        items.push ["Files", kapa_document_files_path] if @current_user.manage?(:document, :delegate => :file)
        items.push ["Forms", kapa_document_forms_path] if @current_user.manage?(:document, :delegate => :form)
        items.push ["Test Scores", kapa_document_exams_path] if @current_user.manage?(:document, :delegate => :exam)
        items.push ["Reports", kapa_document_reports_path] if @current_user.manage?(:document, :delegate => :reports)
      when "advising"
        items.push ["Sessions", kapa_advising_sessions_path] if @current_user.read?(:advising)
      when "course"
        items.push ["Rosters", kapa_course_offers_path] if @current_user.read?(:course)
      when "practicum"
        items.push ["Placements", kapa_practicum_placements_path] if @current_user.read?(:practicum)
        items.push ["Sites", kapa_practicum_sites_path] if @current_user.read?(:practicum)
      when "admin"
        items.push ["Terms", kapa_admin_terms_path] if @current_user.manage?(:admin, :delegate => :term)
        items.push ["Programs", kapa_admin_programs_path] if @current_user.manage?(:admin, :delegate => :program)
        items.push ["Assessments", kapa_admin_rubrics_path] if @current_user.manage?(:admin, :delegate => :rubric)
        items.push ["Datasets", kapa_admin_datasets_path] if @current_user.manage?(:admin)
        items.push ["User Accounts", kapa_admin_users_path] if @current_user.manage?(:admin, :delegate => :user)
#      items.push ["User Activities", kapa_admin_users_path(:action => :logs)]   if @current_user.manage?(:admin, :delegate => :user)
        items.push ["System Properties", kapa_admin_properties_path] if @current_user.manage?(:admin)
    end
    items
  end

  #This method returns nil if it encounters any nil object during reflection.
  def rsend(object, *args, &block)
    obj = object
    args.each do |a|
      b = (a.is_a?(Array) && a.last.is_a?(Proc) ? a.pop : block)
      obj = obj.__send__(*a, &b) if obj
    end
    obj
  end
end
