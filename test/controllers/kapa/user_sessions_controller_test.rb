require 'test_helper'

class Kapa::UserSessionsControllerTest < ActionController::TestCase
  setup do
    @kapa_user_session = kapa_user_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_user_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_user_session" do
    assert_difference('Kapa::UserSession.count') do
      post :create, kapa_user_session: {  }
    end

    assert_redirected_to kapa_user_session_path(assigns(:kapa_user_session))
  end

  test "should show kapa_user_session" do
    get :show, id: @kapa_user_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_user_session
    assert_response :success
  end

  test "should update kapa_user_session" do
    patch :update, id: @kapa_user_session, kapa_user_session: {  }
    assert_redirected_to kapa_user_session_path(assigns(:kapa_user_session))
  end

  test "should destroy kapa_user_session" do
    assert_difference('Kapa::UserSession.count', -1) do
      delete :destroy, id: @kapa_user_session
    end

    assert_redirected_to kapa_user_sessions_path
  end
end
