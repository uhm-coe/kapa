class Person < KapaBaseModel
#class Person < ActiveRecord::Base
  self.table_name = :persons
  #Main module associations
  has_one  :contact, :as => :entity, :autosave => true
  has_many :curriculums
  has_many :users

  #Artifact module associations
  has_many :forms
  has_many :documents
  has_many :exams

  #Advising module associations
  has_many :advising_sessions

  #Curriculum module associations
  #has_many :curriculum_events
  #has_many :curriculum_enrollments,
  #         :class_name => "CurriculumEvent",
  #         :conditions => "curriculum_events.context = 'enrollment' and curriculum_events.status = 'Y'"

  #Placement module associations
  has_one :practicum_profile
  has_many :practicum_assignments

  #Assessment module associations
  has_many :course_registrations

  validates_uniqueness_of :id_number, :allow_nil => false, :message => "is already used.", :scope => :status, :if => :verified?
  validates_presence_of :last_name, :first_name, :on => :create
#  validates_length_of :ssn, :is => 9, :allow_blank => true
#  validates_numericality_of :ssn, :allow_blank => true

  before_save :format_fields

  def format_fields
    self.id_number = nil if self.id_number.blank?
    ssn_formatted = self.ssn.gsub(/\D/, "") if self.ssn
    unless ssn_formatted.blank?
      self.ssn_crypted = Person.encrypt(ssn_formatted)
      self.ssn = "X" * ssn_formatted.length
    end
  end

  def full_name
    if last_name.blank? and first_name.blank?
      return "N/A"
    else
      name = "#{last_name}, #{first_name}"
#      name << "*" if not verified?
      return name
    end
  end

  def ldap_user
    self.users.first(:conditions => "users.category = 'ldap'")
  end

  def practicum_profiles
    if self.practicum_profile
      [self.practicum_profile]
    else
      []
    end
  end

  def details(obj)
    obj.instance_variable_set(:@contact, self.contact)

    #TODO add public or dept conditions
    docs_forms_list = []
    docs_forms_list += self.documents
    docs_forms_list += self.forms
    obj.instance_variable_set(:@docs_forms_list, docs_forms_list)
  end

  def ethnicity_desc
    return ApplicationProperty.lookup_description("ethnicity", self.ethnicity)
  end

  def verified?
    return self.status == "V"
  end

  def deleted?
    return self.status == "D"
  end

  def promote
    self.source = "UH LDAP"
    self.status = "V"
  end

  def merge(another_person, options = {})
    ActiveRecord::Base.transaction do
      #Merge attributes to this person
      another_person.attributes.each_pair do |key, value|
        self.[]=(key, value) if self.[](key).blank?
      end

      #Include all depending objects and deactivate another person
      if options[:include_associations]

        Person.reflect_on_all_associations.each do |assoc|
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

  def self.search(filter, options = {})
    if filter.blank?
      return []
    end

    persons = Person.includes(:contact).where("status <> 'D'")
    persons = persons.where(:status => "V") if options[:verified]

    if filter.key =~ Regexp.new(Rails.configuration.regex_id_number)
      persons = persons.where(:id_number => filter.key)
    elsif filter.key =~  Regexp.new(Rails.configuration.regex_email, true)
      persons = persons.where(:email => filter.key)
    elsif filter.key =~  /\d+/
      persons = persons.where("contacts.cur_phone" => filter.key, "contacts.per_phone" => filter.key, "contacts.mobile_phone" => filter.key)
    elsif filter.key =~  /\w+,\s*\w+/
      keys = filter.key.split(/,\s*/)
      persons = persons.where{(last_name =~ "%#{keys[0]}%") | (first_name =~ "%#{keys[1]}%")}
    else
      persons = persons.where{(first_name =~ "%#{filter.key}%") | (last_name =~ "%#{filter.key}%") | (other_name =~ "%#{filter.key}%")}
    end

    return persons.order("status desc").limit(100)
  end

  def self.lookup(key, options ={})
    person_local = self.search(filter.new(:key => key), options).first
    if person_local.blank? and DirectoryService.is_defined?
      person_remote = DirectoryService.person(key)

      #Make sure the person found in LDAP is not in the local database.
      #This avoids the problem when email is missing in local record but exists in LDAP.
      if person_remote
        person_local = Person.find_by_id_number(person_remote.id_number)
        if person_local
          person_local.merge(person_remote)
          return person_local
        end
      end

      return person_remote
    end

    return person_local
  end
end
