require 'test_helper'

class Kapa::TransitionPointsControllerTest < ActionController::TestCase
  setup do
    @kapa_transition_point = kapa_transition_points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_transition_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_transition_point" do
    assert_difference('Kapa::TransitionPoint.count') do
      post :create, kapa_transition_point: {  }
    end

    assert_redirected_to kapa_transition_point_path(assigns(:kapa_transition_point))
  end

  test "should show kapa_transition_point" do
    get :show, id: @kapa_transition_point
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_transition_point
    assert_response :success
  end

  test "should update kapa_transition_point" do
    patch :update, id: @kapa_transition_point, kapa_transition_point: {  }
    assert_redirected_to kapa_transition_point_path(assigns(:kapa_transition_point))
  end

  test "should destroy kapa_transition_point" do
    assert_difference('Kapa::TransitionPoint.count', -1) do
      delete :destroy, id: @kapa_transition_point
    end

    assert_redirected_to kapa_transition_points_path
  end
end
