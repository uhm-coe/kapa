require 'test_helper'

class CourseRegistrationTest < ActiveSupport::TestCase
  test "is valid without any attributes" do
    course_registration = CourseRegistration.new
    assert course_registration.valid?
  end

  test "returns course offer term description as term description" do
    course_offer = CourseOffer.new(:id => 101, :term_id => 2024241530)
    course_offer.save
    course_registration = CourseRegistration.new(:course_offer_id => course_offer.id)
    assert_equal "Spring 2015", course_registration.term_desc
  end

  test "returns course offer subject as subject" do
    course_registration = CourseRegistration.new(:course_offer_id => 7)
    assert_equal "EDEA", course_registration.subject
  end
end
