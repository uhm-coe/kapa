require 'test_helper'

class Kapa::UsersControllerTest < ActionController::TestCase
  setup do
    @kapa_user = kapa_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_user" do
    assert_difference('Kapa::User.count') do
      post :create, kapa_user: {  }
    end

    assert_redirected_to kapa_user_path(assigns(:kapa_user))
  end

  test "should show kapa_user" do
    get :show, id: @kapa_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_user
    assert_response :success
  end

  test "should update kapa_user" do
    patch :update, id: @kapa_user, kapa_user: {  }
    assert_redirected_to kapa_user_path(assigns(:kapa_user))
  end

  test "should destroy kapa_user" do
    assert_difference('Kapa::User.count', -1) do
      delete :destroy, id: @kapa_user
    end

    assert_redirected_to kapa_users_path
  end
end
