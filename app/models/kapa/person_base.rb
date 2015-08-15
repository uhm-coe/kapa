module Kapa::PersonBase
  extend ActiveSupport::Concern

  included do
    self.table_name = :persons
    has_one :contact, :as => :entity, :autosave => true
    has_many :curriculums
    has_many :users
    has_many :forms
    has_many :files
    has_many :exams
    has_many :advising_sessions
    has_many :practicum_placements
    has_many :course_registrations

    validates_uniqueness_of :id_number, :allow_nil => false, :message => "is already used.", :scope => :status, :if => :verified?
    validates_presence_of :last_name, :first_name, :on => :create
    #  validates_length_of :ssn, :is => 9, :allow_blank => true
    #  validates_numericality_of :ssn, :allow_blank => true

    before_save :format_fields
  end

  def format_fields
    self.id_number = nil if self.id_number.blank?
    ssn_formatted = self.ssn.gsub(/\D/, "") if self.ssn
    unless ssn_formatted.blank?
      self.ssn_crypted = Kapa::Person.encrypt(ssn_formatted)
      self.ssn = "X" * ssn_formatted.length
    end
  end

  def full_name
    "#{last_name}, #{first_name}"
  end

  def details(obj)
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
            assoc.klass.update_all("#{assoc.foreign_key} = #{self.id}", "#{assoc.foreign_key} = #{another_person.id}")
          elsif assoc.macro == :has_one
            if self.send(assoc.name).nil?
              assoc.klass.update_all("#{assoc.foreign_key} = #{self.id}", "#{assoc.foreign_key} = #{another_person.id}")
            end
          end
        end

        #Deactivate another person
        another_person.update_attributes(:status => "D",
                                         :id_number => nil,
                                         :note => "Merged to #{self.id}")
      end
      self.save!
    end
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]

      if filter.blank?
        return []
      end

      persons = Kapa::Person.eager_load(:contact).where("status <> 'D'")
      persons = persons.where(:status => "V") if options[:verified]

      if filter.key =~ Regexp.new(Rails.configuration.regex_id_number)
        persons = persons.where(:id_number => filter.key)
      elsif filter.key =~ Regexp.new(Rails.configuration.regex_email, true)
        persons = persons.where(:email => filter.key)
      elsif filter.key =~ /\d+/
        persons = persons.column_matches("contacts.cur_phone" => filter.key, "contacts.per_phone" => filter.key, "contacts.mobile_phone" => filter.key)
      elsif filter.key =~ /\w+,\s*\w+/
        keys = filter.key.split(/,\s*/)
        persons = persons.column_matches(:last_name => keys[0], :first_name => keys[1])
      else
        persons = persons.column_matches(:first_name => filter.key, :last_name => filter.key, :other_name => filter.key)
      end

      return persons.order("status desc").limit(100)
    end

    def lookup(key)
      filter = OpenStruct.new(:key => key)
      #Key must be unique attribute.
      unless filter.key =~ Regexp.new(Rails.configuration.regex_id_number) or filter.key =~ Regexp.new(Rails.configuration.regex_email, true)
        return false
      end
      person = self.search(:filter => filter).first
      if person.blank?
        person_remote = Kapa::Person.lookup_remote(key).first

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
      end

      return person
    end

    def lookup_remote(key)
      #Implement a way to load single person data from a remote datasource in main application.
      #This method is called from lookup method if the system cannot find a person in the local database.
      return []
    end
  end
end
