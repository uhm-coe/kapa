class AssessmentCriterion < ApplicationBaseModel
  self.inheritance_column = nil
  belongs_to :assessment_rubric
  has_many :assessment_scores
  validates_uniqueness_of :criterion, :scope => :assessment_rubric_id
  validates_presence_of :criterion
  before_save :format_fields

  def format_fields
    standard.to_s.strip!
    criterion.to_s.strip!
    criterion_desc.to_s.strip!
    criterion_desc.to_s.sub!("\n", "")
  end

  def criterion_detail
    criterion_html
  end
end
