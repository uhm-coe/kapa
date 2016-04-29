require 'test_helper'

class Kapa::TransitionActionsControllerTest < ActionController::TestCase
  setup do
    @kapa_transition_action = kapa_transition_actions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_transition_actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_transition_action" do
    assert_difference('Kapa::TransitionAction.count') do
      post :create, kapa_transition_action: {  }
    end

    assert_redirected_to kapa_transition_action_path(assigns(:kapa_transition_action))
  end

  test "should show kapa_transition_action" do
    get :show, id: @kapa_transition_action
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_transition_action
    assert_response :success
  end

  test "should update kapa_transition_action" do
    patch :update, id: @kapa_transition_action, kapa_transition_action: {  }
    assert_redirected_to kapa_transition_action_path(assigns(:kapa_transition_action))
  end

  test "should destroy kapa_transition_action" do
    assert_difference('Kapa::TransitionAction.count', -1) do
      delete :destroy, id: @kapa_transition_action
    end

    assert_redirected_to kapa_transition_actions_path
  end
end
