require 'test_helper'

class Kapa::AssessmentCriterionsControllerTest < ActionController::TestCase
  setup do
    @kapa_assessment_criterion = kapa_assessment_criterions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_assessment_criterions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_assessment_criterion" do
    assert_difference('Kapa::AssessmentCriterion.count') do
      post :create, kapa_assessment_criterion: {  }
    end

    assert_redirected_to kapa_assessment_criterion_path(assigns(:kapa_assessment_criterion))
  end

  test "should show kapa_assessment_criterion" do
    get :show, id: @kapa_assessment_criterion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_assessment_criterion
    assert_response :success
  end

  test "should update kapa_assessment_criterion" do
    patch :update, id: @kapa_assessment_criterion, kapa_assessment_criterion: {  }
    assert_redirected_to kapa_assessment_criterion_path(assigns(:kapa_assessment_criterion))
  end

  test "should destroy kapa_assessment_criterion" do
    assert_difference('Kapa::AssessmentCriterion.count', -1) do
      delete :destroy, id: @kapa_assessment_criterion
    end

    assert_redirected_to kapa_assessment_criterions_path
  end
end
