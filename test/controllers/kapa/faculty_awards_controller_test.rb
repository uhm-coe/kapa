require 'test_helper'

class Kapa::FacultyAwardsControllerTest < ActionController::TestCase
  setup do
    @kapa_faculty_award = kapa_faculty_awards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_faculty_awards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_faculty_award" do
    assert_difference('Kapa::FacultyAward.count') do
      post :create, kapa_faculty_award: {  }
    end

    assert_redirected_to kapa_faculty_award_path(assigns(:kapa_faculty_award))
  end

  test "should show kapa_faculty_award" do
    get :show, id: @kapa_faculty_award
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_faculty_award
    assert_response :success
  end

  test "should update kapa_faculty_award" do
    patch :update, id: @kapa_faculty_award, kapa_faculty_award: {  }
    assert_redirected_to kapa_faculty_award_path(assigns(:kapa_faculty_award))
  end

  test "should destroy kapa_faculty_award" do
    assert_difference('Kapa::FacultyAward.count', -1) do
      delete :destroy, id: @kapa_faculty_award
    end

    assert_redirected_to kapa_faculty_awards_path
  end
end
