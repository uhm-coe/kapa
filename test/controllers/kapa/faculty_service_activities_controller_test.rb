require 'test_helper'

class Kapa::FacultyServiceActivitiesControllerTest < ActionController::TestCase
  setup do
    @kapa_faculty_service_activity = kapa_faculty_service_activities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_faculty_service_activities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_faculty_service_activity" do
    assert_difference('Kapa::FacultyServiceActivity.count') do
      post :create, kapa_faculty_service_activity: {  }
    end

    assert_redirected_to kapa_faculty_service_activity_path(assigns(:kapa_faculty_service_activity))
  end

  test "should show kapa_faculty_service_activity" do
    get :show, id: @kapa_faculty_service_activity
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_faculty_service_activity
    assert_response :success
  end

  test "should update kapa_faculty_service_activity" do
    patch :update, id: @kapa_faculty_service_activity, kapa_faculty_service_activity: {  }
    assert_redirected_to kapa_faculty_service_activity_path(assigns(:kapa_faculty_service_activity))
  end

  test "should destroy kapa_faculty_service_activity" do
    assert_difference('Kapa::FacultyServiceActivity.count', -1) do
      delete :destroy, id: @kapa_faculty_service_activity
    end

    assert_redirected_to kapa_faculty_service_activities_path
  end
end
