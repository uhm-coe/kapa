require 'test_helper'

class AdvisingSessionTest < ActiveSupport::TestCase
  test "is invalid without a session date" do
    advising_session = AdvisingSession.new(:session_type => "email", :person_id => 1)
    assert !advising_session.valid?
  end

  test "is invalid without a session type" do
    advising_session = AdvisingSession.new(:session_date => DateTime.now, :person_id => 1)
    assert !advising_session.valid?
  end

  # test "is invalid without a person id" do
  #   advising_session = AdvisingSession.new(:session_date => DateTime.now, :session_type => "email")
  #   assert !advising_session.valid?
  # end

  test "returns identity note as name if anonymous" do
    advising_session = AdvisingSession.new(:session_date => DateTime.now, :session_type => "email", :person_id => 0, :identity_note => "Anonymous Person")
    advising_session.save
    assert_equal "Anonymous Person*", advising_session.name
  end

  test "returns person full name as name if not anonymous" do
    advising_session = AdvisingSession.new(:session_date => DateTime.now, :session_type => "email", :person_id => 1)
    advising_session.save
    assert_equal "Gardner, Zelenia", advising_session.name
  end

  test "returns anonymous if person id is 0" do
    advising_session = AdvisingSession.new(:session_date => DateTime.now, :session_type => "email", :person_id => 0)
    advising_session.save
    assert advising_session.anonymous?
  end

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
