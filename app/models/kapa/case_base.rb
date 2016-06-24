module Kapa::CaseBase
  extend ActiveSupport::Concern

  included do
    belongs_to :person
    belongs_to :curriculum
    has_many :case_actions
    has_one :last_case_action,
            -> { where("case_actions.id =
                                        (select a.id
                                         from case_actions a
                                         where a.case_id = case_actions.case_id
                                         order by sequence desc, action_date desc, id desc
                                         limit 1)")},
            :class_name => "CaseAction"

    has_many :case_incidents
    has_many :case_involvements
    has_many :case_communications
    has_many :cases, :through => :case_involvements
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments
    has_many :files, :as => :attachable
    has_many :forms, :as => :attachable

    serialize :category, Kapa::CsvSerializer
    validates :reported_at, :type, :case_name, :presence => true, :on => :update
    validates :case_number_alt, :uniqueness => true, :on => :update, :allow_blank => true
    before_save :update_case_type
    before_save :update_case_name
    before_save :update_status_timestamp
  end

  def update_case_type
    #TODO: Implement case type logic
    self.type = "t9"
    return self
  end

  def update_case_name
    if self.case_name.blank? or self.case_name.include? "?"
      self.case_name = default_case_name
    end
    return self
  end


  def update_status_timestamp
    self.status_updated_at = DateTime.now if self.status_changed?
  end

  def case_number
    if case_number_alt.present?
      case_number_alt
    else
      "#{self.dept}#{self.id.to_s.rjust(8, '0')}"
    end
  end

  def default_case_name
    reporting_party = self.case_involvements.where(:type => "CO").first
    responding_party = self.case_involvements.where(:type => "RE").first
    "#{reporting_party ? reporting_party.person.full_name_ordered : "?"} vs. #{responding_party ? responding_party.person.full_name_ordered : "?"}"
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

  def documents
    documents = []
    documents += self.files.eager_load(:person)
    documents += self.forms.eager_load(:person)
    return documents
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      cases = Kapa::Case.eager_load([:user_assignments, {:case_involvements => :person}, :last_case_action]).order("cases.id DESC")
      cases = cases.where("cases.status" => filter.case_status) if filter.case_status.present?
      cases = cases.where("cases.type" => filter.case_type.to_s) if filter.case_type.present?
      cases = cases.where("cases.id" => filter.case_id.to_s) if filter.case_id.present?
      cases = cases.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
        when 30
          # Do nothing
        when 20
          cases = cases.depts_scope(filter.user.depts, filter.user.id)
        when 10
          cases = cases.assigned_scope(filter.user.id)
        else
          cases = cases.where("1 = 2") # Do not list any objects
      end
      return cases
    end

    def csv_format
      {:id_number => [:person, :id_number],
       :last_name => [:person, :last_name],
       :first_name => [:person, :first_name],
       :cur_street => [:person, :cur_street],
       :cur_city => [:person, :cur_city],
       :cur_state => [:person, :cur_state],
       :cur_postal_code => [:person, :cur_postal_code],
       :cur_phone => [:person, :cur_phone],
       :email => [:person, :email],
       :case_number => [:id],
       :type_desc => [:type_desc],
       :location_desc => [:location],
       :second_degree => [:location_detail],
       :category_desc => [:category_desc],
       :status_desc => [:status_desc],
       :dept => [:dept],
       :assignee1 => [:user_assignments, :first, :user, :person, :full_name],
       :assignee2 => [:user_assignments, :second, :user, :person, :full_name],
       :assignee3 => [:user_assignments, :third, :user, :person, :full_name],
       :action => [:last_case_action, :action],
       :action_desc => [:last_case_action, :action_desc],
       :action_date => [:last_case_action, :action_date]}
    end
  end

end
