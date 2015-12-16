require 'test_helper'

class TransitionActionTest < ActiveSupport::TestCase
  test "is invalid without an action" do
    transition_action = TransitionAction.new(:action_date => DateTime.now)
    assert !transition_action.valid?
  end

  test "is invalid without an action date" do
    transition_action = TransitionAction.new(:action => "1")
    assert !transition_action.valid?
  end

  test "sets the type to its transition point type" do
    transition_action = TransitionAction.new(:action_date => DateTime.now, :action => "1", :transition_point_id => 1)
    transition_action.save
    assert_equal "admission", transition_action.type
  end

  test "returns action description" do
    transition_action = TransitionAction.new(:action => "1", :type => "admission")
    assert_equal "Admitted", transition_action.action_desc
  end

  test "returns true if the action is admissible" do
    transition_action = TransitionAction.new(:action_date => DateTime.now, :action => "1", :transition_point_id => 1)
    assert transition_action.admissible?
  end
end
