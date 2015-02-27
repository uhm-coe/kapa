class AssessmentScore < KapaBaseModel
  belongs_to :assessment_criterion
  belongs_to :assessment_scorable, :polymorphic => true

  def self.table_for(assessment_rubric, assessment_scorable_type, assessment_scorable_id)
    table = ActiveSupport::OrderedHash.new
    #initialize table first
    for assessment_criterion in assessment_rubric.assessment_criterions
      index = "#{assessment_scorable_id}_#{assessment_criterion.id}"
      table[index] = ""
    end
    #then, fill in scores using ActiveRecord cache.  this is more efficient than filing everything one by one (save SQL execution)
    self.where(["assessment_scorable_type = ? and assessment_scorable_id = ?", assessment_scorable_type, assessment_scorable_id]).each do |s|
      index = "#{s.assessment_scorable_id}_#{s.assessment_criterion_id}"
      table[index] = s.rating if table[index]
    end
    return table
  end
end
