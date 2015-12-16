require 'test_helper'

class ExamTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    exam = Exam.new
    assert exam.valid?
  end

  # test "format_fields"

  # test "examinee_profile"

  # test "examinee_contact"

  test "returns type description" do
    exam = Exam.new(:type => "112")
    assert_equal "Music: Analysis", exam.type_desc
  end

  test "returns report_date as date" do
    exam = Exam.new(:report_date => DateTime.now)
    assert_equal exam.report_date, exam.date
  end

  test "returns type description and report number as name" do
    exam = Exam.new(:type => "110", :report_number => "91749371-01824028")
    assert_equal "Music Education (91749371-01824028)", exam.name
  end

  # test "parse"

  # test "check_format"

  # test "extract_report_number"

  # test "extract_value"

  # test "search"
end
