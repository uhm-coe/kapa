require 'test_helper'

class AssessmentScoreTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    assessment_score = AssessmentScore.new
    assert assessment_score.valid?
  end

  # test "table_for"
end
