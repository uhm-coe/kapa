require 'test_helper'

class Kapa::CasesControllerTest < ActionController::TestCase
  setup do
    @kapa_case = kapa_cases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_cases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_case" do
    assert_difference('Kapa::Case.count') do
      post :create, kapa_case: {  }
    end

    assert_redirected_to kapa_case_path(assigns(:kapa_case))
  end

  test "should show kapa_case" do
    get :show, id: @kapa_case
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_case
    assert_response :success
  end

  test "should update kapa_case" do
    patch :update, id: @kapa_case, kapa_case: {  }
    assert_redirected_to kapa_case_path(assigns(:kapa_case))
  end

  test "should destroy kapa_case" do
    assert_difference('Kapa::Case.count', -1) do
      delete :destroy, id: @kapa_case
    end

    assert_redirected_to kapa_cases_path
  end
end
