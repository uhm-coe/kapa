require 'test_helper'

class AssessmentCriterionTest < ActiveSupport::TestCase
  test "is invalid without a criterion" do
    assessment_criterion = AssessmentCriterion.new
    assert !assessment_criterion.valid?
  end

  test "is invalid if criterion is already taken for a given assessment rubric id" do
    criterion1 = AssessmentCriterion.new(:criterion => "01", :assessment_rubric_id => 1)
    criterion1.save
    assessment_criterion = AssessmentCriterion.new(:criterion => "01", :assessment_rubric_id => 1)
    assert !assessment_criterion.valid?
  end

  # test "format_fields"

  # test "criterion_detail"
end
