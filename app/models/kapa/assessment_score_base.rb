module Kapa::AssessmentScoreBase
  extend ActiveSupport::Concern

  included do
    belongs_to :assessment_criterion
    belongs_to :assessment_scorable, :polymorphic => true
  end

  class_methods do
    def scores(assessment_scorables, assessment_rubric)
      #initialize table first
      scores = ActiveSupport::OrderedHash.new
      assessment_scorables.each do |s|
        assessment_rubric.assessment_criterions.each do |c|
          index = "#{s.id}_#{c.id}"
          scores[index] = ""
        end
      end
      #then, fill in scores using ActiveRecord cache.  this is more efficient than filing everything one by one (save SQL execution)
      self.where(:assessment_scorable_type => assessment_scorables.first.class, :assessment_scorable_id => assessment_scorables.collect {|s| s.id}).each do |score|
        index = "#{score.assessment_scorable_id}_#{score.assessment_criterion_id}"
        scores[index] = score.rating if scores[index]
      end
      return scores
    end
  end
end
