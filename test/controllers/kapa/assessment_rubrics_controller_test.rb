require 'test_helper'

class Kapa::AssessmentRubricsControllerTest < ActionController::TestCase
  setup do
    @kapa_assessment_rubric = kapa_assessment_rubrics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_assessment_rubrics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_assessment_rubric" do
    assert_difference('Kapa::AssessmentRubric.count') do
      post :create, kapa_assessment_rubric: {  }
    end

    assert_redirected_to kapa_assessment_rubric_path(assigns(:kapa_assessment_rubric))
  end

  test "should show kapa_assessment_rubric" do
    get :show, id: @kapa_assessment_rubric
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_assessment_rubric
    assert_response :success
  end

  test "should update kapa_assessment_rubric" do
    patch :update, id: @kapa_assessment_rubric, kapa_assessment_rubric: {  }
    assert_redirected_to kapa_assessment_rubric_path(assigns(:kapa_assessment_rubric))
  end

  test "should destroy kapa_assessment_rubric" do
    assert_difference('Kapa::AssessmentRubric.count', -1) do
      delete :destroy, id: @kapa_assessment_rubric
    end

    assert_redirected_to kapa_assessment_rubrics_path
  end
end
