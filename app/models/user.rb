class User < ApplicationBaseModel
  @available_keys = {}
  attr_accessor :request, :email, :depts

  belongs_to :person
  has_many :user_timestamps

  validate :only_one_ldap_user_per_person
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+(\.[A-Z]{2,4}$)?/i, :message => "is not a valid format", :allow_blank => true
#  validates_uniqueness_of :uid
  validates_presence_of :uid
  validates_presence_of :password, :on => :create, :if => :local?

  before_validation :use_email_as_uid
  before_save :format_fields, :join_attributes
  after_save :update_contact

  acts_as_authentic do |c|
    c.login_field = :uid
    c.merge_validates_length_of_login_field_options :within => 2..100
    c.crypted_password_field = :hashed_password
    c.crypto_provider = ApplicationCryptoProvider
    c.merge_validates_length_of_password_field_options  :on => :create, :if => :local?
    c.require_password_confirmation = false
  end

  def only_one_ldap_user_per_person
    ldap_user = self.person ? self.person.ldap_user : nil
    if ldap_user and ldap_user.id != self.id and self.category == "ldap"
      errors.add_to_base("Person cannot have multiple LDAP account")
    end
  end

  def use_email_as_uid
    self.uid = self.email if self.email.present?
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
    depts.first
  end

  def status_desc
    case status
    when 0 then "In-active"
    when 1 then "Guest"
    when 3 then "User"
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

  def self.selections(options)
    filter = ApplicationFilter.new
    if options[:include].to_s == "employee"
      filter.append_condition("length(users.department) > 0")
      filter.append_condition("users.uid <> persons.id_number")
    else
      filter.append_condition("users.status = 3")
    end
    filter.append_depts_condition("users.dept like ?", options[:depts])
    filter.append_condition(options[:conditions]) if options[:conditions]
    users = []
    User.includes(:person).where(filter.conditions).each do |u|
      users.push ["#{u.person.last_name}, #{u.person.first_name} (#{u.department})", u.id]
      current_value = nil if u.id == current_value
    end

    #This is needed to eliminate a blank field.
    current_value = nil if current_value == "" and options[:include_blank]
    #If the current value does not exist in the list, we have to add it manually.
    users.push [current_value, current_value] if current_value

    return users
  end

  protected
  def valid_credential?(password)
    if category == "ldap"
      ldap = Rails.configuration.ldap
      base = Rails.configuration.ldap_search_base
      filter = "#{Rails.configuration.ldap_attr_uid}=#{self.uid}"
      dn = nil
      ldap.search(:base => base, :filter => filter) do |entry|
        dn = entry.dn
      end
#      logger.debug "---:#{base}, filter:#{filter}, dn: #{dn}"
      return false if dn.nil?

      result = ldap.bind(:method => :simple, :dn => dn , :password => password)
#      logger.debug "---bind?:#{result}"
      return result
    else
      #Use Authlogic authentication for local users.
      valid_password?(password)
    end
  end

  private
  def check_role(level, name, options = {})
    roles = self.role

    #Check if user has access to the key
    if(options[:property] and options[:property][:value] and not manage?(name))
      property_name = options[:property][:name]
      property_value = options[:property][:value]
      #@available_keys is a cache to eliminate duplicate query on single page.
      @available_keys[property_name] = ApplicationProperty.keys(property_name, :depts => self.depts) if @available_keys[property_name].nil?
      return false unless @available_keys[property_name].include?(property_value)
    end

    #Check record ownership
    if(options[:dept] and dept.present?)
      return false unless depts.include?(options[:dept])
    end

    #Check role delegation
    if(options[:delegate])
      delegates = options[:delegate].kind_of?(Array) ? options[:delegate] : Array.[](options[:delegate])
      delegates.each do |d|
        return true if roles.send(name).to_i >= 1 and roles.send("#{name}_#{d}").to_s == "Y"
      end
    end

    return roles.send(name).to_i >= level
  end

  def module_name
    @request.params[:controller].split("/").first
  end
end
