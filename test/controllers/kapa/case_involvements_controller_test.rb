require 'test_helper'

class Kapa::CaseInvolvementsControllerTest < ActionController::TestCase
  setup do
    @kapa_case_involvement = kapa_case_involvements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_case_involvements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_case_involvement" do
    assert_difference('Kapa::CaseInvolvement.count') do
      post :create, kapa_case_involvement: {  }
    end

    assert_redirected_to kapa_case_involvement_path(assigns(:kapa_case_involvement))
  end

  test "should show kapa_case_involvement" do
    get :show, id: @kapa_case_involvement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_case_involvement
    assert_response :success
  end

  test "should update kapa_case_involvement" do
    patch :update, id: @kapa_case_involvement, kapa_case_involvement: {  }
    assert_redirected_to kapa_case_involvement_path(assigns(:kapa_case_involvement))
  end

  test "should destroy kapa_case_involvement" do
    assert_difference('Kapa::CaseInvolvement.count', -1) do
      delete :destroy, id: @kapa_case_involvement
    end

    assert_redirected_to kapa_case_involvements_path
  end
end
