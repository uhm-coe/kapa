require 'test_helper'

class Kapa::PracticumPlacementsControllerTest < ActionController::TestCase
  setup do
    @kapa_practicum_placement = kapa_practicum_placements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_practicum_placements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_practicum_placement" do
    assert_difference('Kapa::PracticumPlacement.count') do
      post :create, kapa_practicum_placement: {  }
    end

    assert_redirected_to kapa_practicum_placement_path(assigns(:kapa_practicum_placement))
  end

  test "should show kapa_practicum_placement" do
    get :show, id: @kapa_practicum_placement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_practicum_placement
    assert_response :success
  end

  test "should update kapa_practicum_placement" do
    patch :update, id: @kapa_practicum_placement, kapa_practicum_placement: {  }
    assert_redirected_to kapa_practicum_placement_path(assigns(:kapa_practicum_placement))
  end

  test "should destroy kapa_practicum_placement" do
    assert_difference('Kapa::PracticumPlacement.count', -1) do
      delete :destroy, id: @kapa_practicum_placement
    end

    assert_redirected_to kapa_practicum_placements_path
  end
end
