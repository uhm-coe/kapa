class Person < ApplicationBaseModel
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
    obj.instance_variable_set(:@forms, self.forms)
    obj.instance_variable_set(:@exam, self.exams.find(:first, :order => "report_date DESC"))
    obj.instance_variable_set(:@exams, self.exams)
#    obj.instance_variable_set(:@practicum_profile, self.practicum_profile)

    filter = ApplicationFilter.new
    filter.append_depts_condition("public = 'Y' or dept like ?", obj.instance_variable_get(:@current_user).depts)

    docs_forms_list = []
    docs_forms_list += self.documents
    docs_forms_list += self.forms
    obj.instance_variable_set(:@docs_forms_list, docs_forms_list)
    # obj.instance_variable_set(:@documents, self.documents.find(:all, :conditions => filter.conditions))

    filter = ApplicationFilter.new
    filter.append_condition("module = 'form'")
    filter.append_depts_condition("dept like ?", obj.instance_variable_get(:@current_user).depts)
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
          logger.debug "association="
          logger.debug assoc.inspect
          if assoc.macro == :has_many
            assoc.klass.update_all("#{assoc.primary_key_name} = #{self.id}", "#{assoc.primary_key_name} = #{another_person.id}")
          elsif assoc.macro == :has_one
            if self.send(assoc.name).nil?
              assoc.klass.update_all("#{assoc.primary_key_name} = #{self.id}", "#{assoc.primary_key_name} = #{another_person.id}")
            end
          end
        end

        #Deactivate another person
        another_person.update_attributes(:status => "D",
                                         :id_number => nil,
                                         :note => "Consolidated to #{self.id}")
      end
    end
  end

  def self.search(first_or_all, key, options = {})
#    logger.debug "key = '#{key}' length = #{key.length}"
    if key.blank?
      return first_or_all.to_s == "first" ? nil : {}
    end

    filter = ApplicationFilter.new(:key => key)
    case key
    when /^[0-9]+/
      if key.length == 9
        filter.append_condition("ssn = ?", :key)
      elsif key.length == 8
        filter.append_condition("id_number = ?", :key)
      else
        filter.append_condition("contacts.cur_phone like ? or contacts.per_phone like ? or contacts.mobile_phone like ?", :key, :like => true)
      end
    when /^[A-Z0-9_%+-]+@hawaii.edu$/i
      filter.append_condition("persons.email like ? or persons.email_alt like ?", :key)
    when /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
      filter.append_condition("contacts.email like ?", :key)
    when /\w+,\s*\w+/
      keys = key.split(/,\s*/)
      filter.last_name = keys[0]
      filter.first_name = keys[1]
      filter.append_condition("last_name like ?", :last_name, :like => true)
      filter.append_condition("first_name like ?", :first_name, :like => true)
    else
      filter.append_condition("first_name like ? or last_name like ? or other_name like ?", :key, :like => true)
    end

    filter.append_condition("status <> 'D'")
    filter.append_condition("status = 'V'") if options[:verified]
    results = Person.find(first_or_all, :include => :contact, :conditions => filter.conditions, :order => "status desc", :limit => 100)
    logger.debug "--local search found person = #{results.inspect}"
    if results.blank?
      logger.debug "---LDAP search initiated for #{key}"
      results.push(DirectoryService.person(key))
      logger.debug "---LDAP result #{results.inspect}"

      #Make sure the LDAP result does not have in local database.
      if results and results.is_a? Person
        existing_person = Person.find_by_id_number(results.id_number)
        if existing_person
          existing_person.merge(results)
          results = existing_person
        end
      end
    end
    return results
  end
end
