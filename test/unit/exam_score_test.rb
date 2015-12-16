require 'test_helper'

class ExamScoreTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    exam_score = ExamScore.new
    assert exam_score.valid?
  end

  test "returns subject description" do
    exam_score = ExamScore.new(:subject => "EDEA")
    assert_equal "EDEA", exam_score.subject_desc
  end

  # test "subscores"
end
