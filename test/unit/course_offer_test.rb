require 'test_helper'

class CourseOfferTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    course_offer = CourseOffer.new
    assert course_offer.valid?
  end

  # test "assessment_rubrics"

  test "returns subject, number, and section as name" do
    course_offer = CourseOffer.new(:subject => "EDEA", :number => "767", :section => "423")
    course_offer.save
    assert_equal "EDEA767-423", course_offer.name
  end

  test "returns term description" do
    course_offer = CourseOffer.new(:term_id => 2024241530)
    course_offer.save
    assert_equal "Spring 2015", course_offer.term_desc
  end

  # test "table_for"

  # test "progress"

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
