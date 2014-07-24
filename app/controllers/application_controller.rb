# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :validate_authkey
  before_filter :validate_login, :except => [:index, :login, :logout, :error]
  before_filter :check_read_permission, :except => [:index, :login, :logout, :error]
  before_filter :check_write_permission, :only => [:new, :create, :update]
  before_filter :check_manage_permission, :only => [:destroy, :export, :import, :search]
  after_filter :put_timestamp
  helper :all
  helper_method :url_for, :module_name, :current_academic_period, :next_academic_period, :menu_items

  def validate_authkey
    if validate_authkey? and params[:authkey] != authkey(params[:id])
      flash[:notice] = "URL you requested was invalid!"
      redirect_to(error_path) and return false
    end
  end

  def validate_login
    @current_user_session = UserSession.find
    @current_user = @current_user_session.user if @current_user_session
    @current_user.request = request
    unless @current_user_session and @current_user and @current_user.status >= 3 and @current_user.emp_status >= 1
      @current_user_session.destroy if @current_user_session
      flash[:notice] = "You are not authorized to use this system!  Please contact system administrator."
      cas_logout(root_url) and return
    end
  end

  def check_read_permission
    unless @current_user.read?(module_name)
      flash[:notice] = "You do not have a permission to read on the #{module_name} module."
      redirect_to(error_path) and return false
    end
  end

  def check_write_permission
    unless @current_user.write?(module_name, :delegate => params[:action])
      flash[:notice] = "You do not have a permission to write records on the #{module_name} module."
      redirect_to(error_path) and return false
    end
  end

  def check_manage_permission
    unless @current_user.write?(module_name, :delegate => params[:action])
      flash[:notice] = "You do not have a permission to manage records on the #{module_name} module."
      redirect_to(error_path) and return false
    end
  end

  def put_timestamp
    user = @current_user ? @current_user : @current_student_user
    if user
      user.request = request if user.request.nil?
      user.put_timestamp
    end
    logger.debug "---inspection begin----"
    logger.debug params.inspect
    logger.debug session.inspect
    logger.debug @filter.inspect if @filter
    logger.debug @current_user.inspect if @current_user
    logger.debug UserSession.find.inspect
    logger.debug "---inspection end----"
  end

  def cas_login(return_url, options = {})
    cas_host = AppConfig.cas_host
    cas_login_path = AppConfig.cas_login_path
    redirect_to "#{cas_host}#{cas_login_path}?service=#{return_url}"
  end

  def cas_validate(ticket, return_url, options = {})
    cas_host = AppConfig.cas_host
    cas_validate_path = AppConfig.cas_validate_path
    uri = URI.parse(cas_host)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    body = http.start{ |h| h.get("#{cas_validate_path}?service=#{return_url}&ticket=#{ticket}") }.body
    results = body.split(/\n/)

    if results[0] == "yes"
      uid = results[1]
      id_number = results[2]
      user = User.where(:uid => uid, :category => "ldap").first
      if(user.nil?)
        person = Person.search(:first, id_number.to_s, :verified => true)
        if person.nil?
          logger.error "Invalid ID Number: #{id_number}"
          return nil
        end
        person.id_number = id_number #UH LDAP omits id_number for off-site access.
        person.save if person.new_record?
        user = person.ldap_user
        user = person.users.build(:uid => uid, :category => "ldap", :status => 1, :emp_status => 0) if user.nil?
        user.uid = uid
        unless user.save
          logger.error "Fail to create the new ldap user: #{user.errors.inspect}"
          return nil
        end
      end

      if user.emp_status < 3
        if body.include?("=staff") or body.include?("=faculty")
          user.update_attribute(:emp_status, 2)
        else
          user.update_attribute(:emp_status, 0)
        end
      end

      return user
    else
      return nil
    end
  end

  def cas_logout(return_url, options = {})
    cas_host = AppConfig.cas_host
    cas_logout_path = AppConfig.cas_logout_path
    redirect_to "#{cas_host}#{cas_logout_path}?service=#{return_url}&url=#{return_url}"
  end

  def render_node(nid)
    host = "http://coe.hawaii.edu"
    path = "/api/node"
    uri = URI.parse(host)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    res = http.start{ |h| h.get("#{path}/#{node}.json") }
    if res.code == "200"
      json = ActiveSupport::JSON.decode(res.body)
      return json["body"]["und"][0]["value"]
    else
      return "Error #{res.code}: #{res.message}"
    end
  end
  
  def url_for(options = {})
    if options.kind_of?(Hash)
      #This will avoid generating absolute path when hash is passed in.
      options[:only_path] = true if options[:controller].blank?

      if validate_authkey?(options[:action])
        id = options[:id].kind_of?(ActiveRecord::Base) ? options[:id].id.to_s : options[:id].to_s
        options[:authkey] = authkey(id)
      end
    end
    super(options)
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
      flash[:notice1] = "We are sorry, but something went wrong."
      render_notice and return false
    else
      flash[:notice] = "We are sorry, but something went wrong."
      redirect_to(AppConfig.routing_mode == "student" ? student_error_path : error_path) and return false     
    end
  end
    
  private
  def authkey(string)
    Digest::SHA1.hexdigest("#{current_academic_period}#{string}")
  end

  def validate_authkey?(action = params[:action])
    Rails.application.config.validate_authkey.include? action.to_s
  end

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


  def next_academic_period
    value = ApplicationProperty.where("code > ?", current_academic_period).order("code").first
    logger.debug "----next academic period: #{value.code}"
    return value.code
  end
  
  def menu_items(name, options = {})
    items = []
    case name.to_s
    when "main"
      items.push ["Search Person", main_persons_path(:action => :list)]  if @current_user.manage?(:main, :delegate => :search)
      items.push ["Program Cohorts", main_curriculums_path(:action => :list)]  if @current_user.read? (:main)
      items.push ["Transition Points", main_transition_points_path(:action => :list)] if @current_user.read?(:main)
    when "artifact"
      items.push ["Forms", artifact_forms_path(:action => :list)] if @current_user.manage?(:artifact, :delegate => :form)
      items.push ["Praxis Scores", artifact_exams_path(:action => :list)] if @current_user.manage?(:artifact, :delegate => :exam)
    when "advising"
      items.push ["Sessions", advising_sessions_path(:action => :list)]  if @current_user.read?(:advising)
    when "course"
      items.push ["Rosters", course_rosters_path(:action => :list)] if @current_user.read?(:course)
    when "practicum"
      items.push ["Placement Audits", practicum_placements_path(:action => :list)]  if @current_user.read?(:practicum)
      items.push ["Mentor Assignments", practicum_assignments_path(:action => :list)]  if @current_user.read?(:practicum)
      items.push ["Schools", practicum_schools_path(:action => :list)]  if @current_user.read?(:practicum)
    when "admin"
      items.push ["Programs", admin_programs_path(:action => :list)]  if @current_user.manage?(:admin, :delegate => :program)
      items.push ["Assessments", admin_rubrics_path(:action => :list)]  if @current_user.manage?(:admin, :delegate => :rubric)
      items.push ["SSN Reporting", admin_restricted_reports_path(:action => :list)]  if @current_user.manage?(:admin, :delegate => :restricted_report)
      items.push ["User Accounts", admin_users_path(:action => :list)]  if @current_user.manage?(:admin, :delegate => :user)
      items.push ["User Activities", admin_users_path(:action => :logs)]   if @current_user.manage?(:admin, :delegate => :user)
      items.push ["System Properties", admin_properties_path(:action => :list)]   if @current_user.manage?(:admin)
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
