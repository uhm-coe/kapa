require 'test_helper'

class Kapa::CoursesControllerTest < ActionController::TestCase
  setup do
    @kapa_course = kapa_courses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_courses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_course" do
    assert_difference('Kapa::Course.count') do
      post :create, kapa_course: {  }
    end

    assert_redirected_to kapa_course_path(assigns(:kapa_course))
  end

  test "should show kapa_course" do
    get :show, id: @kapa_course
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_course
    assert_response :success
  end

  test "should update kapa_course" do
    patch :update, id: @kapa_course, kapa_course: {  }
    assert_redirected_to kapa_course_path(assigns(:kapa_course))
  end

  test "should destroy kapa_course" do
    assert_difference('Kapa::Course.count', -1) do
      delete :destroy, id: @kapa_course
    end

    assert_redirected_to kapa_courses_path
  end
end
