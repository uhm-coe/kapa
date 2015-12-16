require 'test_helper'

class ProgramOfferTest < ActiveSupport::TestCase
  test "is invalid without a distribution" do
    program_offer = ProgramOffer.new
    assert !program_offer.valid?
  end

  test "is invalid if distribution is already taken for a given program id" do
    program_offer = ProgramOffer.new(:distribution => "MAN", :program_id => 1)
    assert !program_offer.valid?
  end

  # test "remove_extra_values"

  # test "join_attributes"

  # test "selections"
end
