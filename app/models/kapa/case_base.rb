module Kapa::CaseBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :curriculum
    belongs_to :term
    has_many :case_actions
    has_many :person_references, :as => :referenceable
    has_many :involved_persons, :through => :person_references, :source => :person
    has_one :last_case_action,
            -> { where("case_actions.id =
                                        (select a.id
                                         from case_actions a
                                         where a.case_id = case_actions.case_id
                                         order by sequence desc, action_date desc, id desc
                                         limit 1)")},
            :class_name => "CaseAction"

    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments
    has_many :files, :as => :attachable
    has_many :forms, :as => :attachable

    validates_presence_of :term_id, :type

    before_save :update_status_timestamp
  end

  def update_status_timestamp
    self.status_updated_at = DateTime.now if self.status_changed?
  end

  def term_desc
    Kapa::Term.lookup_description(self.term_id)
  end

  def category_desc
    return Kapa::Property.lookup_description("#{type}_category", category)
  end

  def priority_desc
    return Kapa::Property.lookup_description("#{type}_priority", priority)
  end

  def status_desc
    return Kapa::Property.lookup_description("#{type}_status", status)
  end

  def type_desc
    return Kapa::Property.lookup_description(:case, type)
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      cases = Kapa::Case.eager_load([:person, :curriculum, {:curriculum => :program}]).order("persons.last_name, persons.first_name")
      cases = cases.where("cases.term_id" => filter.term_id) if filter.term_id.present?
      cases = cases.where("cases.status" => filter.status) if filter.status.present?
      cases = cases.where("cases.type" => filter.type.to_s) if filter.type.present?
      cases = cases.where("curriculums.program_id" => filter.program_id) if filter.program_id.present?
      cases = cases.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      cases = cases.where("curriculums.major_primary" => filter.major) if filter.major.present?
      cases = cases.where("curriculums.cohort" => filter.cohort) if filter.cohort.present?
      cases = cases.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
        when 3
          # Do nothing
        when 2
          cases = cases.depts_scope(filter.user.depts)
        when 1
          cases = cases.assigned_scope(filter.user.id)
        else
          cases = cases.where("1 = 2") # Do not list any objects
      end
      return cases
    end

    def csv_format
      {:id_number => [:curriculum, :person, :id_number],
       :last_name => [:curriculum, :person, :last_name],
       :first_name => [:curriculum, :person, :first_name],
       :cur_street => [:curriculum, :person, :contact, :cur_street],
       :cur_city => [:curriculum, :person, :contact, :cur_city],
       :cur_state => [:curriculum, :person, :contact, :cur_state],
       :cur_postal_code => [:curriculum, :person, :contact, :cur_postal_code],
       :cur_phone => [:curriculum, :person, :contact, :cur_phone],
       :email => [:curriculum, :person, :contact, :email],
       :program_desc => [:curriculum, :program, :description],
       :track_desc => [:curriculum, :track_desc],
       :major_primary_desc => [:curriculum, :major_primary_desc],
       :major_secondary_desc => [:curriculum, :major_secondary_desc],
       :distribution_desc => [:curriculum, :distribution_desc],
       :location_desc => [:curriculum, :location_desc],
       :second_degree => [:curriculum, :second_degree],
       :term_desc => [:term, :description],
       :category_desc => [:category_desc],
       :priority_desc => [:priority_desc],
       :status_desc => [:status_desc],
       :user_primary => [:user_primary, :person, :full_name],
       :user_secondary => [:user_secondary, :person, :full_name],
       :action => [:last_case_action, :action],
       :action_desc => [:last_case_action, :action_desc],
       :action_date => [:last_case_action, :action_date]}
    end
  end

end
