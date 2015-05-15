module Kapa::Concerns::User
  extend ActiveSupport::Concern

  included do
    @available_keys = {}
    attr_accessor :request, :email, :depts

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
  end # included

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
    dept.to_s.split(/,\s*/)
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

  def role
    self.deserialize(:role, :as => OpenStruct)
  end

  def read?(name = module_name, options = {})
    check_role(1, name, options)
  end

  def write?(name = module_name, options = {})
    check_role(2, name, options)
  end

  def manage?(name = module_name, options = {})
    check_role(3, name, options)
  end

  def access_scope(name = module_name, condition = nil)
    roles = self.role
    roles.send("#{name}_list").to_i
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

  def check_role(level, name, options = {})
    roles = self.role

    #Check if user has access to the key
    if (options[:property] and options[:property][:value] and not manage?(name))
      property_name = options[:property][:name]
      property_value = options[:property][:value]
      #@available_keys is a cache to eliminate duplicate query on single page.
      @available_keys[property_name] = Kapa::ApplicationProperty.keys(property_name, :depts => self.depts) if @available_keys[property_name].nil?
      return false unless @available_keys[property_name].include?(property_value)
    end

    #Check record ownership
    if (options[:dept] and dept.present?)
      return false unless depts.include?(options[:dept])
    end

    #Check role delegation
    if (options[:delegate])
      delegates = options[:delegate].kind_of?(Array) ? options[:delegate] : Array.[](options[:delegate])
      delegates.each do |d|
        return true if roles.send(name).to_i >= 1 and roles.send("#{name}_#{d}").to_s == "Y"
      end
    end

    return roles.send(name).to_i >= level
  end

  def module_name
    @request.params[:controller].split("/").second
  end

  module ClassMethods
    def selections(options)
      users = where(:status => 3)
      users = users.depts_scope(options[:depts]) if options[:depts]
      users = users.where(options[:conditions]) if options[:conditions]
      users.includes(:person).collect do |u|
        ["#{u.person.last_name}, #{u.person.first_name} (#{u.department})", u.id]
      end
    end

    def search(filter, options = {})
      users = Kapa::User.includes([:person])
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
       :role_main,
       :role_artifact,
       :role_advising,
       :role_curriculum,
       :role_assessment,
       :role_practicum,
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
       c.rsend(:role, :main),
       c.rsend(:role, :document),
       c.rsend(:role, :advising),
       c.rsend(:role, :curriculum),
       c.rsend(:role, :course),
       c.rsend(:role, :practicum),
       c.rsend(:dept),
       c.rsend(:category)]
    end
  end

end
