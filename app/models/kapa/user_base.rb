module Kapa::UserBase
  extend ActiveSupport::Concern

  included do
    @available_keys = {}
    attr_accessor :email

    belongs_to :person
    has_many :notifications
    has_many :user_assignments
    has_many :user_timestamps

    validates_format_of :email, :with => /@/, :message => "is not a valid format", :allow_blank => true
    validates_uniqueness_of :uid
    validates_presence_of :uid, :person_id
    validates_presence_of :password, :on => :create, :if => :local?
    validates :uid, :length => { :minimum => 2, :maximum => 100}, :if => :local?
    validates :password, :length => {:minimum => 5}, :on => :create, :if => :local?

    before_validation :use_email_as_uid
    before_save :format_fields
    after_save :update_person

    acts_as_authentic do |c|
      c.login_field = :uid
      c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
      c.crypted_password_field = :hashed_password
      c.require_password_confirmation = false
      c.logged_in_timeout = 12.hours

      #Please note that this method cannot be overridden in user.rb on your app.
      #App specific custom authlogic configuration should be made in config/initializers/authlogic.rb.
      Rails.configuration.acts_as_authentic_options.each_pair do |key, value|
        c.send(key, value)
      end if Rails.configuration.respond_to?(:acts_as_authentic_options)
    end
  end

  def use_email_as_uid
    self.uid = self.email if self.email.present?
  end

  def format_fields
    self.uid = self.uid.to_s.downcase
  end

  def update_person
    self.person.update_columns(:email_alt => self.uid) if local? and self.uid_changed?
  end

  def status_desc
    user_status = Rails.configuration.user_status.select {|s| s[1] == status.to_s}.first
    user_status[0] if user_status
  end

  def category_desc
    user_category = Rails.configuration.user_category.select {|s| s[1] == category.to_s}.first
    user_category[0] if user_category
  end

  def active?
    status > 0
  end

  def local?
    category == "local"
  end

  def init_permission
    if @permission.nil?
      if self.role.present? and Rails.configuration.roles[self.role].present?
        @permission = OpenStruct.new(Rails.configuration.roles[self.role])
      else
        @permission = OpenStruct.new
      end
    end
  end

  def check_permission(name, permission_code)
    init_permission
    @permission.send("#{name}").to_s.include?(permission_code)
  end

  def access_scope(name, condition = nil)
    init_permission
    @permission.send("#{name}_scope").to_i
  end

  def apply_role(name)
    if Rails.configuration.roles.keys.include?(name)
      self.role = name
    end
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
      result = ldap.bind(:method => :simple, :dn => dn, :password => password)
      logger.error "*ERROR* LDAP Login Error for #{uid}: #{ldap.get_operation_result.code} #{ldap.get_operation_result.message}" if result.nil?
      return result
    else
      #Use Authlogic authentication for local users.
      valid_password?(password)
    end
  end

  class_methods do
    def selections(options = {})
      users = where("length(primary_dept) > 0")
      users = users.depts_scope(options[:depts]) if options[:depts].present?
      users = users.where(options[:conditions]) if options[:conditions].present?
      users.eager_load(:person).collect do |u|
        ["#{u.person.full_name} (#{u.primary_dept})", u.id]
      end.sort_by(&:first)
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      users = Kapa::User.eager_load(:person).order("users.uid")
      users = users.where("users.status" => filter.status) if filter.status.present?
      users = users.where("users.role" => filter.role) if filter.role.present?
      users = users.where("users.category" => filter.category) if filter.category.present?
      users = users.column_contains({"users.dept" => filter.dept}) if filter.dept.present?
      users = users.column_matches("users.uid" => filter.user_key, "persons.last_name" => filter.user_key, "persons.first_name" => filter.user_key) if filter.user_key.present?
      return users
    end

    # def csv_format
    #   {:uid => [:uid],
    #    :id_number => [:person, :id_number],
    #    :last_name => [:person, :last_name],
    #    :first_name => [:person, :first_name],
    #    :position => [:position],
    #    :primary_dept => [:primary_dept],
    #    :role => [:role],
    #    :status => [:status],
    #    :dept => [:dept, [:join, ","]],
    #    :category => [:category]}
    # end
  end
end
