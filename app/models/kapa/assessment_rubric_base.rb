module Kapa::AssessmentRubricBase
  extend ActiveSupport::Concern

  included do
    serialize :course, Kapa::CsvSerializer
    serialize :program, Kapa::CsvSerializer
    serialize :transition_point, Kapa::CsvSerializer
    has_many :assessment_criterions, -> {order("assessment_criterions.criterion")}, :dependent => :destroy
    validates_presence_of :title
  end

  def effective_term
    "#{Kapa::Term.find(self.start_term_id).description} - #{Kapa::Term.find(self.end_term_id).description}" if self.start_term_id.present? and self.end_term_id.present?
  end

  class_methods do
    def search(filter, options = {})
      assessment_rubrics = Kapa::AssessmentRubric.eager_load([:assessment_criterions])
      assessment_rubrics = assessment_rubrics.column_matches(:title => filter.title) if filter.title.present?
      assessment_rubrics = assessment_rubrics.column_contains(:program => filter.program) if filter.program.present?
      assessment_rubrics = assessment_rubrics.column_contains(:course => filter.course) if filter.course.present?
      assessment_rubrics = assessment_rubrics.column_contains(:transition_point => filter.transition_point) if filter.transition_point.present?
      return assessment_rubrics
    end
  end
end
