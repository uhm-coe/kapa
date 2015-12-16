require 'test_helper'

class TransitionPointTest < ActiveSupport::TestCase
  test "is invalid without a term id" do
    transition_point = TransitionPoint.new(:type => "admission")
    assert !transition_point.valid?
  end

  test "is invalid without a type" do
    transition_point = TransitionPoint.new(:term_id => 2024241530)
    assert !transition_point.valid?
  end

  # test "update_status_timestamp"

  test "returns term description" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "admission")
    transition_point.save
    assert_equal "Spring 2015", transition_point.term_desc
  end

  test "returns category description" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "admission", :category => "N")
    transition_point.save
    assert_equal "New Student", transition_point.category_desc
  end

  test "returns priority description" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "admission", :priority => "P")
    transition_point.save
    assert_equal "Priority", transition_point.priority_desc
  end

  test "returns status description" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "admission", :status => "L")
    transition_point.save
    assert_equal "Letter Sent", transition_point.status_desc
  end

  test "returns type description" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "admission")
    transition_point.save
    assert_equal "Admission", transition_point.type_desc
  end

  test "returns true if category is entrance" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "admission")
    transition_point.save
    assert transition_point.entrance?
  end

  test "returns true if category is exit" do
    transition_point = TransitionPoint.new(:curriculum_id => 1, :term_id => 2024241530, :type => "graduation")
    transition_point.save
    assert transition_point.exit?
  end

  # test "assessment_rubrics"

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
