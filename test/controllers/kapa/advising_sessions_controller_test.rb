require 'test_helper'

class Kapa::AdvisingSessionsControllerTest < ActionController::TestCase
  setup do
    @kapa_advising_session = kapa_advising_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_advising_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_advising_session" do
    assert_difference('Kapa::AdvisingSession.count') do
      post :create, kapa_advising_session: {  }
    end

    assert_redirected_to kapa_advising_session_path(assigns(:kapa_advising_session))
  end

  test "should show kapa_advising_session" do
    get :show, id: @kapa_advising_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_advising_session
    assert_response :success
  end

  test "should update kapa_advising_session" do
    patch :update, id: @kapa_advising_session, kapa_advising_session: {  }
    assert_redirected_to kapa_advising_session_path(assigns(:kapa_advising_session))
  end

  test "should destroy kapa_advising_session" do
    assert_difference('Kapa::AdvisingSession.count', -1) do
      delete :destroy, id: @kapa_advising_session
    end

    assert_redirected_to kapa_advising_sessions_path
  end
end
