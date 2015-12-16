require 'test_helper'

class EnrollmentTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    enrollment = Enrollment.new
    assert enrollment.valid?
  end

  # test "practicum_assignments_select"

  test "returns term description" do
    enrollment = Enrollment.new(:term_id => 2024241530)
    enrollment.save
    assert_equal "Spring 2015", enrollment.term_desc
  end

  # test "returns assignment description"

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
