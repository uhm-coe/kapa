require 'test_helper'

class ProgramTest < ActiveSupport::TestCase
  test "is invalid without a code" do
    program = Program.new
    assert !program.valid?
  end

  test "is invalid if code is already taken" do
    program = Program.new(:code => "ECED-MED")
    assert !program.valid?
  end

  # test "remove_extra_values"

  # test "join_attributes"

  test "returns degree description" do
    program = Program.new(:code => "", :degree => "BED")
    assert_equal "Bachelor of Education", program.degree_desc
  end

  # test "selections"

  # test "search"
end
