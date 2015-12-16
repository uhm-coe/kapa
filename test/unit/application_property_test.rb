require 'test_helper'

class ApplicationPropertyTest < ActiveSupport::TestCase
  test "is invalid without a code" do
    application_property = ApplicationProperty.new
    assert !application_property.valid?
  end

  test "is invalid if code is already taken for a given name" do
    application_property = ApplicationProperty.new(:name => "advising_task", :code => "Other")
    assert !application_property.valid?
  end

  # test "refresh_cache"

  # test "selections"

  # test "lookup_description"

  # test "lookup_description_detail"

  # test "lookup_category"

  # test "keys"

  # test "append"

  # test "search"
end
