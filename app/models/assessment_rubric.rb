class AssessmentRubric < KapaBaseModel
  attr_accessor :courses, :programs, :transition_points
  has_many :assessment_criterions, :order => "assessment_criterions.criterion", :dependent => :destroy
  validates_presence_of :title
  before_validation :remove_extra_values
  before_save :join_attributes

  def remove_extra_values
    remove_values(self.courses)
    remove_values(self.programs)
    remove_values(self.transition_points)
  end

  def join_attributes
    self.course = @courses ? @courses.join(",") : ""
    self.program = @programs ? @programs.join(",") : ""
    self.transition_point = @transition_points ? @transition_points.join(",") : ""
  end

  def effective_term
    "#{Term.find(self.start_term_id).description} - #{Term.find(self.end_term_id).description}" if self.start_term_id.present? and self.end_term_id.present?
  end

  def self.search(filter, options = {})
    assessment_rubrics = AssessmentRubric.includes([:assessment_criterions])
    assessment_rubrics = assessment_rubrics.column_matches(:title => filter.title) if filter.title.present?
    assessment_rubrics = assessment_rubrics.column_contains(:program => filter.program) if filter.program.present?
    assessment_rubrics = assessment_rubrics.column_contains(:course => filter.course) if filter.course.present?
    assessment_rubrics = assessment_rubrics.column_contains(:transition_point => filter.transition_point) if filter.transition_point.present?
    return assessment_rubrics
  end
end
