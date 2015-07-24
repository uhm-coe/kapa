module Kapa::KapaControllerBase
  extend ActiveSupport::Concern

  included do
    layout "/kapa/layouts/kapa"
    protect_from_forgery
    before_filter :check_if_route_is_enabled, :except => [:welcome, :login, :logout, :error]
    before_filter :validate_login, :except => [:welcome, :login, :logout, :error]
    before_filter :check_read_permission, :except => [:welcome, :login, :logout, :error]
    before_filter :check_write_permission, :only => [:new, :create, :update, :destroy]
    before_filter :check_manage_permission, :only => [:export, :import]
    after_filter :put_timestamp
    helper :all
    helper_method :url_for, :menu_items
  end

  def check_if_route_is_enabled
    unless Rails.configuration.available_routes.include?(controller_name)
      flash[:danger] = "#{controller_name} is not available."
      redirect_to(kapa_error_path) and return false
    end
  end

  def validate_login
    @current_user_session = Kapa::UserSession.find
    if @current_user_session
      @current_user = @current_user_session.user
      @current_user.request = request
    end
    unless @current_user_session and @current_user and @current_user.status >= 3
      @current_user_session.destroy if @current_user_session
      flash[:danger] = "You are not authorized to use this system!  Please contact system administrator."
      redirect_to(kapa_root_url) and return
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

  def check_manage_permission
    unless @current_user.write?(controller_name, :delegate => params[:action])
      flash[:danger] = "You do not have a manage permission on #{controller_name}."
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

  def controller_name
    params[:controller].gsub("/", "_")
  end

  def filter(options = {})
    name = "filter_#{controller_name}".to_sym
    session[name] = filter_defaults if session[name].nil?
    session[name].update(params[:filter]) if params[:filter].present?
    session[name].update(options) if options.present?
    filter = OpenStruct.new(session[name])
    filter.user = @current_user
    return filter
  end

  def filter_defaults
    {:key => "",
     :type => :admission,
     :active => 1,
     :name => :major,
     :date_start => Date.today,
     :date_end => Date.today,
     :term_id => Kapa::Term.current_term.id,
     :start_term_id => Kapa::Term.current_term.id,
     :end_term_id => Kapa::Term.current_term.id,
     :per_page => Rails.configuration.items_per_page}
  end

  def menu_items(name, options = {})
    items = []
    case name.to_s
      when "main"
        items.push ["Search Person", kapa_main_persons_path] if @current_user.read?(:kapa_main_persons)
        items.push ["Cohorts", kapa_main_curriculums_path] if @current_user.read? (:kapa_main_curriculums)
        items.push ["Transition Points", kapa_main_transition_points_path] if @current_user.read?(:kapa_main_transition_points)
        items.push ["Enrollments", kapa_main_enrollments_path] if @current_user.read?(:kapa_main_enrollments)
      when "document"
        items.push ["Files", kapa_document_files_path] if @current_user.read?(:kapa_document_files)
        items.push ["Forms", kapa_document_forms_path] if @current_user.read?(:kapa_document_forms)
        items.push ["Test Scores", kapa_document_exams_path] if @current_user.read?(:kapa_document_exams)
        items.push ["Reports", kapa_document_reports_path] if @current_user.read?(:kapa_document_reports)
      when "advising"
        items.push ["Sessions", kapa_advising_sessions_path] if @current_user.read?(:kapa_advising_sessions)
      when "course"
        items.push ["Rosters", kapa_course_offers_path] if @current_user.read?(:kapa_course_offers)
      when "practicum"
        items.push ["Placements", kapa_practicum_placements_path] if @current_user.read?(:kapa_practicum_placements)
        items.push ["Sites", kapa_practicum_sites_path] if @current_user.read?(:kapa_practicum_sites)
      when "admin"
        items.push ["Terms", kapa_admin_terms_path] if @current_user.manage?(:kapa_admin_terms)
        items.push ["Programs", kapa_admin_programs_path] if @current_user.manage?(:kapa_admin_programs)
        items.push ["Assessments", kapa_admin_rubrics_path] if @current_user.manage?(:kapa_admin_rubrics)
        items.push ["Datasets", kapa_admin_datasets_path] if @current_user.manage?(:kapa_admin_datasets)
        items.push ["User Accounts", kapa_admin_users_path] if @current_user.manage?(:kapa_admin_users)
        items.push ["System Properties", kapa_admin_properties_path] if @current_user.manage?(:kapa_admin_properties)
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
