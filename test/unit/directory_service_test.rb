require 'test_helper'

class DirectoryServiceTest < ActiveSupport::TestCase
  test "is defined if LDAP configuration is present" do
    assert !DirectoryService.is_defined?
  end

  # test "authenticate"

  # test "person"

  # test "persons"

  test "returns LDAP as source" do
    assert_equal "LDAP", DirectoryService.source
  end
end
