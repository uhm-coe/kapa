require 'test_helper'

class Kapa::AdvisingSessionsControllerTest < ActionController::TestCase

  setup :activate_authlogic
  setup do
    Kapa::UserSession.create(Kapa::User.find_by_uid("admin"))
    @advising_session = Kapa::AdvisingSession.find(1)
    @person = Kapa::Person.find(1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advising_sessions)
  end

  test "should get new" do
    get :new, id: @person
    assert_response :success
  end

  test "should create advising_session" do
    assert_difference('Kapa::AdvisingSession.count') do
      post :create, advising_session: {person_id: @person, session_date: Date.today, type: "email"}
    end

    assert_redirected_to kapa_advising_session_path(assigns(:advising_session))
  end

  test "should show advising_session" do
    get :show, id: @advising_session
    assert_response :success
  end

  test "should update advising_session" do
    patch :update, id: @advising_session, advising_session: {note: "Here is my update"}
    assert_redirected_to kapa_advising_session_path(assigns(:advising_session))
  end

  test "should destroy advising_session" do
    assert_difference('Kapa::AdvisingSession.count', -1) do
      delete :destroy, id: @advising_session
    end

    assert_redirected_to kapa_person_path(assigns(:person))
  end
end
