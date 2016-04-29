require 'test_helper'

class Kapa::EnrollmentsControllerTest < ActionController::TestCase
  setup do
    @kapa_enrollment = kapa_enrollments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_enrollments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_enrollment" do
    assert_difference('Kapa::Enrollment.count') do
      post :create, kapa_enrollment: {  }
    end

    assert_redirected_to kapa_enrollment_path(assigns(:kapa_enrollment))
  end

  test "should show kapa_enrollment" do
    get :show, id: @kapa_enrollment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_enrollment
    assert_response :success
  end

  test "should update kapa_enrollment" do
    patch :update, id: @kapa_enrollment, kapa_enrollment: {  }
    assert_redirected_to kapa_enrollment_path(assigns(:kapa_enrollment))
  end

  test "should destroy kapa_enrollment" do
    assert_difference('Kapa::Enrollment.count', -1) do
      delete :destroy, id: @kapa_enrollment
    end

    assert_redirected_to kapa_enrollments_path
  end
end
