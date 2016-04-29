require 'test_helper'

class Kapa::UserAssignmentsControllerTest < ActionController::TestCase
  setup do
    @kapa_user_assignment = kapa_user_assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_user_assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_user_assignment" do
    assert_difference('Kapa::UserAssignment.count') do
      post :create, kapa_user_assignment: {  }
    end

    assert_redirected_to kapa_user_assignment_path(assigns(:kapa_user_assignment))
  end

  test "should show kapa_user_assignment" do
    get :show, id: @kapa_user_assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_user_assignment
    assert_response :success
  end

  test "should update kapa_user_assignment" do
    patch :update, id: @kapa_user_assignment, kapa_user_assignment: {  }
    assert_redirected_to kapa_user_assignment_path(assigns(:kapa_user_assignment))
  end

  test "should destroy kapa_user_assignment" do
    assert_difference('Kapa::UserAssignment.count', -1) do
      delete :destroy, id: @kapa_user_assignment
    end

    assert_redirected_to kapa_user_assignments_path
  end
end
