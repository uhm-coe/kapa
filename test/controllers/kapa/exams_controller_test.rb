require 'test_helper'

class Kapa::ExamsControllerTest < ActionController::TestCase
  setup do
    @kapa_exam = kapa_exams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_exams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_exam" do
    assert_difference('Kapa::Exam.count') do
      post :create, kapa_exam: {  }
    end

    assert_redirected_to kapa_exam_path(assigns(:kapa_exam))
  end

  test "should show kapa_exam" do
    get :show, id: @kapa_exam
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_exam
    assert_response :success
  end

  test "should update kapa_exam" do
    patch :update, id: @kapa_exam, kapa_exam: {  }
    assert_redirected_to kapa_exam_path(assigns(:kapa_exam))
  end

  test "should destroy kapa_exam" do
    assert_difference('Kapa::Exam.count', -1) do
      delete :destroy, id: @kapa_exam
    end

    assert_redirected_to kapa_exams_path
  end
end
