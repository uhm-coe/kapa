require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    dataset = Dataset.new
    assert dataset.valid?
  end

  # test "load"

  # test "to_json"

  # test "table_name"

  # test "db_connection"
end
