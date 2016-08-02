module Kapa::TransitionPointBase
  extend ActiveSupport::Concern

  included do
    belongs_to :curriculum
    belongs_to :term
    belongs_to :form
    has_many :transition_actions
    has_one :last_transition_action,
            -> { where("transition_actions.id = (select a.id
                                                 from transition_actions a
                                                 where a.transition_point_id = transition_actions.transition_point_id
                                                 order by sequence desc, action_date desc, id desc
                                                 limit 1)")},
            :class_name => "TransitionAction"

    has_many :assessment_scores, :as => :assessment_scorable
    has_many :user_assignments, :as => :assignable
    has_many :users, :through => :user_assignments

    validates_presence_of :curriculum_id, :term_id, :type

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
    return Kapa::Property.lookup_description(:transition_point, type)
  end

  def entrance?
    Kapa::Property.lookup_category(:transition_point, type) == "entrance"
  end

  def exit?
    Kapa::Property.lookup_category(:transition_point, type) == "exit"
  end

  def assessment_rubrics
    rubrics = Kapa::AssessmentRubric.eager_load(:assessment_criterions)
    rubrics = rubrics.where(["? between (select code from terms where id = assessment_rubrics.start_term_id) and (select code from terms where id = assessment_rubrics.end_term_id)", Kapa::Term.find(self.term_id).code])
    rubrics = rubrics.column_contains("assessment_rubrics.transition_point" => self.type)
    rubrics = rubrics.column_contains("assessment_rubrics.program" => self.curriculum.program.code).order("assessment_rubrics.title, assessment_criterions.criterion")
    if rubrics.blank?
      return [Kapa::AssessmentRubric.new(:title => "Not Defined")]
    else
      return rubrics
    end
  end

  class_methods do
    def search(options = {})
      filter = options[:filter].is_a?(Hash) ? OpenStruct.new(options[:filter]) : options[:filter]
      transition_points = Kapa::TransitionPoint.eager_load([{:users => :person}, :curriculum, {:curriculum => [:program, :person]}, :last_transition_action]).order("persons.last_name, persons.first_name")
      transition_points = transition_points.where("transition_points.term_id" => filter.term_id) if filter.term_id.present?
      transition_points = transition_points.where("transition_points.status" => filter.status) if filter.status.present?
      transition_points = transition_points.where("transition_points.type" => filter.type.to_s) if filter.type.present?
      transition_points = transition_points.where("curriculums.program_id" => filter.program_id) if filter.program_id.present?
      transition_points = transition_points.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
      transition_points = transition_points.where("curriculums.major_primary" => filter.major) if filter.major.present?
      transition_points = transition_points.where("curriculums.cohort" => filter.cohort) if filter.cohort.present?
      transition_points = transition_points.assigned_scope(filter.user_id) if filter.user_id.present?

      case filter.user.access_scope
        when 30
          # Do nothing
        when 20
          transition_points = transition_points.depts_scope(filter.user.depts, filter.user.id)
        when 10
          transition_points = transition_points.assigned_scope(filter.user.id)
        else
          transition_points = transition_points.where("1 = 2") # Do not list any objects
      end
      return transition_points
    end

    def csv_format
      {:id_number => [:curriculum, :person, :id_number],
       :last_name => [:curriculum, :person, :last_name],
       :first_name => [:curriculum, :person, :first_name],
       :cur_street => [:curriculum, :person, :cur_street],
       :cur_city => [:curriculum, :person, :cur_city],
       :cur_state => [:curriculum, :person, :cur_state],
       :cur_postal_code => [:curriculum, :person, :cur_postal_code],
       :cur_phone => [:curriculum, :person, :cur_phone],
       :email => [:curriculum, :person, :email],
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
       :action => [:last_transition_action, :action],
       :action_desc => [:last_transition_action, :action_desc],
       :action_date => [:last_transition_action, :action_date]}
    end
  end

end
