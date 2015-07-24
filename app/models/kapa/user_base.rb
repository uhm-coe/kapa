module Kapa::UserBase
  extend ActiveSupport::Concern

  included do
    @available_keys = {}
    attr_accessor :request, :email
    attr_writer :depts

    belongs_to :person
    has_many :user_timestamps

    validates_format_of :email, :with => /@/, :message => "is not a valid format", :allow_blank => true
    validates_uniqueness_of :uid
    validates_presence_of :uid
    validates_presence_of :password, :on => :create, :if => :local?

    before_validation :use_email_as_uid, :remove_extra_values
    before_save :format_fields, :join_attributes
    after_save :update_contact

    acts_as_authentic do |c|
      c.login_field = :uid
      c.merge_validates_length_of_login_field_options :within => 2..100
      c.crypted_password_field = :hashed_password
      c.merge_validates_length_of_password_field_options :on => :create, :if => :local?
      c.require_password_confirmation = false
    end
  end

  def use_email_as_uid
    self.uid = self.email if self.email.present?
  end

  def remove_extra_values
    remove_values(@depts)
  end

  def format_fields
    self.uid = self.uid.to_s.downcase
  end

  def join_attributes
    self.dept = @depts.join(",") if @depts
  end

  def update_contact
    if self.category == "local" and self.person
      contact = self.person.contact ||= self.person.create_contact
      contact.update_attribute(:email, self.uid)
    end
  end

  def put_timestamp
    self.user_timestamps.create(:path => @request.path,
                                :remote_ip => @request.remote_ip,
                                :agent => @request.env['HTTP_USER_AGENT'].downcase)
  end

  def depts
    self.dept.split(/,\s*/)
  end

  def primary_dept
    depts.first if depts.present?
  end

  def status_desc
    case status
      when 0 then
        "In-active"
      when 1 then
        "Guest"
      when 3 then
        "User"
    end
  end

  def active?
    status > 0
  end

  def local?
    category == "local"
  end

  def permission
    self.deserialize(:permission, :as => OpenStruct)
  end

  def read?(name = controller_name, options = {})
    check_permission(1, name, options)
  end

  def write?(name = controller_name, options = {})
    check_permission(2, name, options)
  end

  def manage?(name = controller_name, options = {})
    check_permission(3, name, options)
  end

  def access_scope(name = controller_name, condition = nil)
    permission = self.permission
    permission.send("#{name}_scope").to_i
  end

  def valid_credential?(password)
    if category == "ldap"
      ldap = Net::LDAP.new(Rails.application.secrets.authentication["ldap"].deep_symbolize_keys)
      base = Rails.application.secrets.authentication["ldap_base"]
      filter = Rails.application.secrets.authentication["ldap_filter"].gsub("?", self.uid)
      dn = nil
      ldap.search(:base => base, :filter => filter) do |entry|
        dn = entry.dn
      end
      ldap.bind(:method => :simple, :dn => dn, :password => password)
    else
      #Use Authlogic authentication for local users.
      valid_password?(password)
    end
  end

  def check_permission(level, name, options = {})
    permission = self.permission

    #Check if user has access to the key
    if (options[:property] and options[:property][:value] and not manage?(name))
      property_name = options[:property][:name]
      property_value = options[:property][:value]
      #@available_keys is a cache to eliminate duplicate query on single page.
      @available_keys[property_name] = Kapa::Property.keys(property_name, :depts => self.depts) if @available_keys[property_name].nil?
      return false unless @available_keys[property_name].include?(property_value)
    end

    #Check record ownership
    if (options[:dept] and dept.present?)
      return false unless depts.include?(options[:dept])
    end

    #Check permission delegation
    if (options[:delegate])
      delegates = options[:delegate].kind_of?(Array) ? options[:delegate] : Array.[](options[:delegate])
      delegates.each do |d|
        return true if permission.send(name).to_i >= 1 and permission.send("#{name}_#{d}").to_s == "Y"
      end
    end

    return permission.send(name).to_i >= level
  end

  def controller_name
    @request.params[:controller].split("/").join("_")
  end

  def apply_role(name)
    permission = {}
    case name.to_s
    when "admin"
      Rails.configuration.available_routes.each do |o|
        permission["#{o}"] = '3'
        permission["#{o}_scope"] = '3'
      end
      when "adviser"
        permission["kapa_main_persons"] = '2'
        permission["kapa_main_persons_scope"] = '2'
        permission["kapa_main_contacts"] = '2'
        permission["kapa_main_contacts_scope"] = '2'
        permission["kapa_main_curriculums"] = '2'
        permission["kapa_main_curriculums_scope"] = '2'
        permission["kapa_main_transition_points"] = '2'
        permission["kapa_main_transition_points_scope"] = '2'
        permission["kapa_main_transition_actions"] = '2'
        permission["kapa_main_transition_actions_scope"] = '2'
        permission["kapa_main_enrollments"] = '2'
        permission["kapa_main_enrollments_scope"] = '2'
        permission["kapa_document_files"] = '2'
        permission["kapa_document_files_scope"] = '2'
        permission["kapa_document_forms"] = '2'
        permission["kapa_document_forms_scope"] = '2'
        permission["kapa_document_exams"] = '2'
        permission["kapa_document_exams_scope"] = '2'
        permission["kapa_advising_sessions"] = '2'
        permission["kapa_advising_sessions_scope"] = '2'
      when "instructor"
        permission["kapa_course_offers"] = '2'
        permission["kapa_course_offers_scope"] = '2'
        permission["kapa_course_registrations"] = '2'
        permission["kapa_course_registrations_scope"] = '2'
    end
    self.serialize(:permission, permission)
  end

  class_methods do
    def selections(options)
      users = where(:status => 3)
      users = users.depts_scope(options[:depts]) if options[:depts]
      users = users.where(options[:conditions]) if options[:conditions]
      users.eager_load(:person).collect do |u|
        ["#{u.person.last_name}, #{u.person.first_name} (#{u.department})", u.id]
      end
    end

    def search(filter, options = {})
      users = Kapa::User.eager_load(:person)
      users = users.where("department" => filter.department) if filter.department.present?
      users = users.where("users.status" => filter.status) if filter.status.present?
      users = users.where("emp_status" => filter.emp_status) if filter.emp_status.present?
      users = users.column_matches("users.uid" => filter.key, "persons.last_name" => filter.key, "persons.first_name" => filter.key) if filter.key.present?
      return users
    end

    def to_csv(filter, options = {})
      users = Kapa::User.search(filter).order("users.uid")
      CSV.generate do |csv|
        csv << self.csv_columns
        users.each do |c|
          csv << self.csv_row(c)
        end
      end
    end

    def csv_columns
      [:uid,
       :id_number,
       :last_name,
       :first_name,
       :position,
       :department,
       :emp_status,
       :status,
       :dept,
       :category]
    end

    def csv_row(c)
      [c.rsend(:uid),
       c.rsend(:person, :id_number),
       c.rsend(:person, :last_name),
       c.rsend(:person, :first_name),
       c.rsend(:position),
       c.rsend(:department),
       c.rsend(:emp_status),
       c.rsend(:status),
       c.rsend(:dept),
       c.rsend(:category)]
    end
  end

end