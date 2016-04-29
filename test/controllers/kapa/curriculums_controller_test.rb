require 'test_helper'

class Kapa::CurriculumsControllerTest < ActionController::TestCase
  setup do
    @kapa_curriculum = kapa_curriculums(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_curriculums)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_curriculum" do
    assert_difference('Kapa::Curriculum.count') do
      post :create, kapa_curriculum: {  }
    end

    assert_redirected_to kapa_curriculum_path(assigns(:kapa_curriculum))
  end

  test "should show kapa_curriculum" do
    get :show, id: @kapa_curriculum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_curriculum
    assert_response :success
  end

  test "should update kapa_curriculum" do
    patch :update, id: @kapa_curriculum, kapa_curriculum: {  }
    assert_redirected_to kapa_curriculum_path(assigns(:kapa_curriculum))
  end

  test "should destroy kapa_curriculum" do
    assert_difference('Kapa::Curriculum.count', -1) do
      delete :destroy, id: @kapa_curriculum
    end

    assert_redirected_to kapa_curriculums_path
  end
end
