class TransitionPoint < ApplicationModel
  self.inheritance_column = nil
  belongs_to :curriculum
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
  
  validates_presence_of :academic_period, :type

  before_save :update_status_timestamp

  def update_status_timestamp
    self.status_updated_at = DateTime.now if self.status_changed?
  end

  def academic_period_desc
    return ApplicationProperty.lookup_description(:academic_period, academic_period)
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

  def assessment_rubrics
    rubrics = AssessmentRubric.includes(:assessment_criterions).where("find_in_set('#{self.type}', assessment_rubrics.transition_point) > 0 and find_in_set('#{self.curriculum.program.code}', assessment_rubrics.program) > 0 and '#{self.academic_period}' between assessment_rubrics.academic_period_start and assessment_rubrics.academic_period_end").order("assessment_rubrics.title, assessment_criterions.criterion")
    if rubrics.blank?
      return [AssessmentRubric.new(:title => "Not Defined")]
    else
      return rubrics
    end
  end

end
