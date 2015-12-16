require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test "is invalid without an entity id" do
    contact = Contact.new
    assert !contact.valid?
  end

  test "is invalid if entity id is already taken for a given entity type" do
    contact1 = Contact.new(:entity_type => "CurriculumEvent", :entity_id => 1)
    contact1.save
    contact = Contact.new(:entity_type => "CurriculumEvent", :entity_id => 1)
    assert !contact.valid?
  end

  # test "format"

  # test "email_alt"
end
