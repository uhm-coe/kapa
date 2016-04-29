require 'test_helper'

class Kapa::FormsControllerTest < ActionController::TestCase
  setup do
    @kapa_form = kapa_forms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_forms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_form" do
    assert_difference('Kapa::Form.count') do
      post :create, kapa_form: {  }
    end

    assert_redirected_to kapa_form_path(assigns(:kapa_form))
  end

  test "should show kapa_form" do
    get :show, id: @kapa_form
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_form
    assert_response :success
  end

  test "should update kapa_form" do
    patch :update, id: @kapa_form, kapa_form: {  }
    assert_redirected_to kapa_form_path(assigns(:kapa_form))
  end

  test "should destroy kapa_form" do
    assert_difference('Kapa::Form.count', -1) do
      delete :destroy, id: @kapa_form
    end

    assert_redirected_to kapa_forms_path
  end
end
