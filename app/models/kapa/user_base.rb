module Kapa::UserBase
  extend ActiveSupport::Concern

  included do
    @available_keys = {}
    attr_accessor :request, :email
    serialize :dept, Kapa::CsvSerializer

    belongs_to :person
    has_many :user_timestamps

    validates_format_of :email, :with => /@/, :message => "is not a valid format", :allow_blank => true
    validates_uniqueness_of :uid
    validates_presence_of :uid
    validates_presence_of :password, :on => :create, :if => :local?

    before_validation :use_email_as_uid
    before_save :format_fields
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

  def format_fields
    self.uid = self.uid.to_s.downcase
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
    self.dept
  end

  def status_desc
    user_status = Rails.configuration.user_status.select {|s| s[1] == status.to_s}.first
    user_status[0]
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

  def check_permission(level, name, options = {})
    return self.permission.send(name).to_i >= level
  end

  def controller_name
    @request.params[:controller].split("/").join("_")
  end

  def read?(name = controller_name, options = {})
    check_permission(10, name, options)
  end

  def write?(name = controller_name, options = {})
    check_permission(20, name, options)
  end

  def manage?(name = controller_name, options = {})
    check_permission(30, name, options)
  end

  def access_scope(name = controller_name, condition = nil)
    permission = self.permission
    permission.send("#{name}_scope").to_i
  end

  def apply_role(name)
    self.serialize(:permission, Rails.configuration.roles[name])
  end

  def valid_credential?(password)
    if category == "ldap"
      ldap = Net::LDAP.new(Rails.configuration.ldap_settings)
      base = Rails.configuration.ldap_base
      filter = Rails.configuration.ldap_filter.gsub("?", self.uid)
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

  class_methods do
    def selections(options = {})
      users = where(:status => 30)
      users = users.depts_scope(options[:depts]) if options[:depts].present?
      users = users.where(options[:conditions]) if options[:conditions].present?
      users.eager_load(:person).collect do |u|
        ["#{u.person.last_name}, #{u.person.first_name} (#{u.primary_dept})", u.id]
      end
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      users = Kapa::User.eager_load(:person).order("users.uid")
      users = users.where("department" => filter.department) if filter.department.present?
      users = users.where("users.status" => filter.status) if filter.status.present?
      users = users.where("users.category" => filter.category) if filter.category.present?
      users = users.column_matches("users.uid" => filter.key, "persons.last_name" => filter.key, "persons.first_name" => filter.key) if filter.key.present?
      return users
    end

    def csv_format
      {:uid => [:uid],
       :id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :position => [:position],
       :department => [:department],
       :emp_status => [:emp_status],
       :status => [:status],
       :dept => [:dept],
       :category => [:category]}
    end
  end
end
