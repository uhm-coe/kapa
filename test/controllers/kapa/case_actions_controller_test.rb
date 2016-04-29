require 'test_helper'

class Kapa::CaseActionsControllerTest < ActionController::TestCase
  setup do
    @kapa_case_action = kapa_case_actions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_case_actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_case_action" do
    assert_difference('Kapa::CaseAction.count') do
      post :create, kapa_case_action: {  }
    end

    assert_redirected_to kapa_case_action_path(assigns(:kapa_case_action))
  end

  test "should show kapa_case_action" do
    get :show, id: @kapa_case_action
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_case_action
    assert_response :success
  end

  test "should update kapa_case_action" do
    patch :update, id: @kapa_case_action, kapa_case_action: {  }
    assert_redirected_to kapa_case_action_path(assigns(:kapa_case_action))
  end

  test "should destroy kapa_case_action" do
    assert_difference('Kapa::CaseAction.count', -1) do
      delete :destroy, id: @kapa_case_action
    end

    assert_redirected_to kapa_case_actions_path
  end
end
