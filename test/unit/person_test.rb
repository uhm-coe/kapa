require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "is invalid without a first name" do
    person = Person.new(:last_name => "World")
    assert !person.valid?
  end

  test "is invalid without a last name" do
    person = Person.new(:first_name => "Hello")
    assert !person.valid?
  end

  # test "formats fields appropriately"

  test "returns full name as a string" do
    person = Person.new(:first_name => "Hello", :last_name => "World")
    assert_equal "World, Hello", person.full_name
  end

  # test "retrieves an ldap user"

  # test "retrieves person details"

  test "returns ethnicity description" do
    person = Person.new(:first_name => "Hello", :last_name => "World", :ethnicity => "Asian")
    assert_equal "Asian", person.ethnicity_desc
  end
end
