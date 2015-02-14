class TransitionPoint < ApplicationBaseModel
  self.inheritance_column = nil
  belongs_to :curriculum
  belongs_to :term
  belongs_to :user_primary,
             :class_name => "User",
             :foreign_key => "user_primary_id"
  belongs_to :user_secondary,
             :class_name => "User",
             :foreign_key => "user_secondary_id"
  has_many   :transition_actions
  has_one    :last_transition_action,
    :class_name => "TransitionAction",
    :conditions => "transition_actions.id =
                            (select a.id
                             from transition_actions a
                             where a.transition_point_id = transition_actions.transition_point_id
                             order by sequence desc, action_date desc, id desc
                             limit 1)"

  has_many :assessment_scores, :as => :assessment_scorable

  validates_presence_of :term_id, :type

  before_save :update_status_timestamp

  def update_status_timestamp
    self.status_updated_at = DateTime.now if self.status_changed?
  end

  def term_desc
    return Term.find(term_id).description
  end

  def category_desc
    return ApplicationProperty.lookup_description("#{type}_category", category)
  end

  def priority_desc
    return ApplicationProperty.lookup_description("#{type}_priority", priority)
  end

  def status_desc
    return ApplicationProperty.lookup_description("#{type}_status", status)
  end

  def type_desc
    return ApplicationProperty.lookup_description(:transition_point, type)
  end

  def entrance?
    ApplicationProperty.lookup_category(:transition_point, self.transition_point.type) == "entrance"
  end

  def exit?
    ApplicationProperty.lookup_category(:transition_point, self.transition_point.type) == "exit"
  end

  def assessment_rubrics
    rubrics = AssessmentRubric.includes(:assessment_criterions).where("find_in_set('#{self.type}', assessment_rubrics.transition_point) > 0 and find_in_set('#{self.curriculum.program.code}', assessment_rubrics.program) > 0 and '#{self.term_id}' between assessment_rubrics.start_term_id and assessment_rubrics.end_term_id").order("assessment_rubrics.title, assessment_criterions.criterion")
    if rubrics.blank?
      return [AssessmentRubric.new(:title => "Not Defined")]
    else
      return rubrics
    end
  end

end
