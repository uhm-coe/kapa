require 'test_helper'

class AssessmentRubricTest < ActiveSupport::TestCase
  test "is invalid without a title" do
    assessment_rubric = AssessmentRubric.new
    assert !assessment_rubric.valid?
  end

  # test "remove_extra_values"

  # test "join_attributes"

  test "returns effective term if start_term_id and end_term_id are present" do
    assessment_rubric = AssessmentRubric.new(:title => "Music Education Fundamentals", :start_term_id => Term.current_term.id, :end_term_id => Term.next_term.id)
    assert_equal "Spring 2015 - Summer 2015", assessment_rubric.effective_term
  end

  # test "search"
end
