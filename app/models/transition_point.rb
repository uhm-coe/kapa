class TransitionPoint < KapaBaseModel
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
    rubrics = AssessmentRubric.includes(:assessment_criterions).where(:term_id => term_ids_by_range(assessment_rubrics.start_term_id, assessment_rubrics.end_term_id)).column_contains(:type, assessment_rubrics.transition_point).column_contains("assessment_rubrics.program", self.curriculum.program.code).order("assessment_rubrics.title, assessment_criterions.criterion")
    if rubrics.blank?
      return [AssessmentRubric.new(:title => "Not Defined")]
    else
      return rubrics
    end
  end

  def self.search(filter, options = {})
    transition_points = TransitionPoint.includes([:curriculum, {:curriculum => :program}, {:curriculum => :person}])
    transition_points = transition_points.where("transition_points.term_id" => filter.term_id) if filter.term_id.present?
    transition_points = transition_points.where("transition_points.status" => filter.status) if filter.status.present?
    transition_points = transition_points.where("transition_points.type" => filter.type.to_s) if filter.type.present?
    transition_points = transition_points.where("programs.code" => filter.program) if filter.program.present?
    transition_points = transition_points.where("curriculums.distribution" => filter.distribution) if filter.distribution.present?
    transition_points = transition_points.where("curriculums.major_primary" => filter.major) if filter.major.present?
    transition_points = transition_points.assigned_scope(filter.user_id) if filter.user_id.present?

    case filter.user.access_scope
    when 3
      # Do nothing
    when 2
          transition_points = transition_points.depts_scope(:dept, filter.user.depts)
      when 1
        transition_points = transition_points.assigned_scope(filter.user.id)
      else
        transition_points = transition_points.where("1 = 2") # Do not list any objects
    end
    return transition_points
  end

  def self.to_csv(filter, options = {})
    transition_points = self.search(filter).order("persons.last_name, persons.first_name")
    CSV.generate do |csv|
      csv << self.csv_columns
      transition_points.each do |c|
        csv << self.csv_row(c)
      end
    end
  end

  def self.csv_columns
    [:id_number,
     :last_name,
     :first_name,
     :ethnicity,
     :gender,
     :email,
     :email_alt,
     :ssn,
     :ssn_agreement,
     :cur_street,
     :cur_city,
     :cur_state,
     :cur_postal_code,
     :cur_phone,
     :program_desc,
     :track_desc,
     :major_primary_desc,
     :major_secondary_desc,
     :distribution_desc,
     :location_desc,
     :second_degree,
     :term_desc,
     :category_desc,
     :priority_desc,
     :status_desc,
     :user_primary,
     :user_secondary,
     :action,
     :action_desc,
     :action_date]
  end

  def self.csv_row(c)
    [c.rsend(:curriculum, :person, :id_number),
     c.rsend(:curriculum, :person, :last_name),
     c.rsend(:curriculum, :person, :first_name),
     c.rsend(:curriculum, :person, :ethnicity),
     c.rsend(:curriculum, :person, :gender),
     c.rsend(:curriculum, :person, :email),
     c.rsend(:curriculum, :person, :contact, :email_alt),
     c.rsend(:curriculum, :person, :ssn),
     c.rsend(:curriculum, :person, :ssn_agreement),
     c.rsend(:curriculum, :person, :contact, :cur_street),
     c.rsend(:curriculum, :person, :contact, :cur_city),
     c.rsend(:curriculum, :person, :contact, :cur_state),
     c.rsend(:curriculum, :person, :contact, :cur_postal_code),
     c.rsend(:curriculum, :person, :contact, :cur_phone),
     c.rsend(:curriculum, :program, :description),
     c.rsend(:curriculum, :track_desc),
     c.rsend(:curriculum, :major_primary_desc),
     c.rsend(:curriculum, :major_secondary_desc),
     c.rsend(:curriculum, :distribution_desc),
     c.rsend(:curriculum, :location_desc),
     c.rsend(:curriculum, :second_degree),
     c.rsend(:term, :description),
     c.rsend(:category_desc),
     c.rsend(:priority_desc),
     c.rsend(:status_desc),
     c.rsend(:user_primary, :person, :full_name),
     c.rsend(:user_secondary, :person, :full_name),
     c.rsend(:last_transition_action, :action),
     c.rsend(:last_transition_action, :action_desc),
     c.rsend(:last_transition_action, :action_date)]
  end
end
