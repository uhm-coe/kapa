require 'test_helper'

class PracticumPlacementTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    practicum_placement = PracticumPlacement.new
    assert practicum_placement.valid?
  end

  test "returns term description" do
    practicum_placement = PracticumPlacement.new(:term_id => 2024241530)
    practicum_placement.save
    assert_equal "Spring 2015", practicum_placement.term_desc
  end

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
