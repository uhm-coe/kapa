module Kapa::PersonBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :persons
    serialize :type, Kapa::CsvSerializer

    has_many :users
    has_many :files
    has_many :forms
    has_many :texts
    has_many :calendar_events

    validates_uniqueness_of :id_number, :allow_nil => false, :message => "is already used.", :scope => :status, :if => :verified?
    validates_presence_of :last_name, :first_name, :on => :create

    before_save :sanitize_attributes
  end


  def sanitize_attributes
    self.id_number = nil if self.id_number.blank?
    self.attributes().each_pair do |k, v|
     if v
       self.[]=(k, v.to_s.downcase) if k =~ /(email$)/
       self.[]=(k, v.gsub(/\D/, "")) if k =~ /(phone$)/
       self.[]=(k, v.to_s.split(' ').map { |w| w.capitalize }.join(' ')) if k =~ /(street$)|(city$)/
       self.[]=(k, v.to_s.upcase) if k =~ /(state$)/
     end
    end
  end

  #depreciated! Add code to controllers to find associated docuemnts.
  # def documents(options = {})
  #   options[:filter] ||= {:user => Kapa::UserSession.find.user}
  #   documents = []
  #   documents += self.files.search(options)
  #   documents += self.forms.search(options)
  #   documents += self.texts.search(options)
  # end

  def full_name(option = nil)
    if option == :ordered
      "#{first_name} #{last_name}"
    elsif option == :short
      "#{first_name} #{last_name[0]}"
    elsif option == :all
      "#{title} #{first_name} #{middle_initial} #{last_name}"
    else
      "#{last_name}, #{first_name}"
    end
  end

  def full_name_ordered
    "#{first_name} #{last_name}"
  end

  def full_name_short
    "#{first_name} #{last_name[0]}"
  end

  def cur_address
    "#{cur_street}<br/>#{cur_city}, #{cur_state} #{cur_postal_code}".html_safe if cur_street.present?
  end

  def per_address
    "#{per_street}<br/>#{per_city}, #{per_state} #{per_postal_code}".html_safe if per_street.present?
  end

  def ethnicity_desc
    return Kapa::Property.lookup_description("ethnicity", self.ethnicity)
  end

  def verified?
    return self.status == "V"
  end

  def deleted?
    return self.status == "D"
  end

  def merge(another_person, options = {})
    ActiveRecord::Base.transaction do
      #Merge attributes to this person
      another_person.attributes.each_pair do |key, value|
        self.[]=(key, value) if self.[](key).blank?
      end

      #Include all depending objects and deactivate another person
      if options[:include_associations]

        Kapa::Person.reflect_on_all_associations.each do |assoc|
          if assoc.macro == :has_many
            assoc.klass.where(assoc.foreign_key => another_person.id).update_all("#{assoc.foreign_key} = #{self.id}")
          end
        end

        #Deactivate another person
        another_person.update_attributes(:status => "D", :id_number => nil, :note => "Merged to #{self.id}")
      end
      self.save!
    end
  end

  def email_preferred
    if self.email.present?
      self.email
    else
      self.email_alt
    end
  end

  class_methods do
    def selections(options = {})
      persons = order(:last_name, :first_name)
      persons = persons.depts_scope(options[:depts]) if options[:depts].present?
      persons = persons.where(options[:conditions]) if options[:conditions].present?
      persons.collect do |p|
        ["#{p.last_name}, #{p.first_name}", p.id]
      end
    end

    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]

      if filter.blank?
        return []
      end

      persons = Kapa::Person.where("status <> 'D'")
      persons = persons.where(:status => "V") if options[:verified]

      if filter.key =~ Regexp.new(Rails.configuration.regex_id_number)
        persons = persons.where(:id_number => filter.key)
      elsif filter.key =~ Regexp.new(Rails.configuration.regex_email, true)
        persons = persons.where(:email => filter.key)
      elsif filter.key =~ /\d+/
        persons = persons.column_matches("cur_phone" => filter.key, "per_phone" => filter.key, "mobile_phone" => filter.key)
      elsif filter.key =~ /\w+,\s*\w+/
        keys = filter.key.split(/,\s*/)
        persons = persons.column_matches(:last_name => keys[0])
        persons = persons.column_matches(:first_name => keys[1])
      else
        persons = persons.column_matches(:first_name => filter.key, :last_name => filter.key, :other_name => filter.key)
      end

      return persons.order("status desc").limit(filter.limit.present? ? filter.limit : 100)
    end

    def lookup(key)
      #Lookup function finds a single record using a key, so the key must be an unique attribute.
      unless key =~ Regexp.new(Rails.configuration.regex_id_number) or key =~ Regexp.new(Rails.configuration.regex_email, true)
        return false
      end

      if key =~ Regexp.new(Rails.configuration.regex_id_number)
        person = Kapa::Person.find_by(:status => "V", :id_number => key)
      elsif key =~ Regexp.new(Rails.configuration.regex_email, true)
        person = Kapa::Person.find_by(:status => "V", :email => key)
      end

      if person.blank?
        person_remote = Kapa::Person.lookup_remote(key)

        #Make sure the person found in the remote database is not in the local database.
        #This avoids the problem when email is missing in local record but exists in external data source.
        if person_remote
          person = Kapa::Person.find_by_id_number(person_remote.id_number)
          if person
            person.merge(person_remote)
            return person
          end
        end

        return person_remote
      else
        return person
      end
    end

    def lookup_remote(key)
      #Implement a way to load single person data from a remote datasource in main application.
      #This method is called from lookup method if the system cannot find a person in the local database.
      return nil
    end
  end
end
