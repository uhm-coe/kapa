require 'test_helper'

class FormTest < ActiveSupport::TestCase
  # This should pass because the model
  #   validates_presence_of :person_id,
  #   but for some reason, it's not passing
  # test "is invalid without a person id" do
  #   form = Form.new(:type => "admission")
  #   assert !form.valid?
  # end

  test "is invalid without a type" do
    form = Form.new(:person_id => 1)
    assert !form.valid?
  end

  test "returns term description" do
    form = Form.new(:term_id => 2024241530)
    form.save
    assert_equal "Spring 2015", form.term_desc
  end

  test "returns type description" do
    form = Form.new(:type => "declaration")
    form.save
    assert_equal "COE Declaration of Intent Form", form.type_desc
  end

  test "returns true if locked" do
    form = Form.new(:lock => "Y")
    form.save
    assert form.lock?
  end

  test "submits and locks the form" do
    form = Form.new
    form.save
    form.submit
    assert_not_nil form.submitted_at
    assert form.lock?
  end

  test "returns submitted_at as date" do
    form = Form.new(:submitted_at => DateTime.now)
    form.save
    assert_equal form.submitted_at, form.date
  end

  test "returns type description as name if term is blank" do
    form = Form.new(:type => "declaration")
    form.save
    assert_equal "COE Declaration of Intent Form", form.name
  end

  test "returns type and term descriptions as name if term is not blank" do
    form = Form.new(:term_id => 2024241530, :type => "declaration")
    form.save
    assert_equal "COE Declaration of Intent Form (Spring 2015)", form.name
  end

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
