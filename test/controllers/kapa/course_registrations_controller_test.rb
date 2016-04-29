require 'test_helper'

class Kapa::CourseRegistrationsControllerTest < ActionController::TestCase
  setup do
    @kapa_course_registration = kapa_course_registrations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_course_registrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_course_registration" do
    assert_difference('Kapa::CourseRegistration.count') do
      post :create, kapa_course_registration: {  }
    end

    assert_redirected_to kapa_course_registration_path(assigns(:kapa_course_registration))
  end

  test "should show kapa_course_registration" do
    get :show, id: @kapa_course_registration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_course_registration
    assert_response :success
  end

  test "should update kapa_course_registration" do
    patch :update, id: @kapa_course_registration, kapa_course_registration: {  }
    assert_redirected_to kapa_course_registration_path(assigns(:kapa_course_registration))
  end

  test "should destroy kapa_course_registration" do
    assert_difference('Kapa::CourseRegistration.count', -1) do
      delete :destroy, id: @kapa_course_registration
    end

    assert_redirected_to kapa_course_registrations_path
  end
end
