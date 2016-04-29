require 'test_helper'

class Kapa::ReportsControllerTest < ActionController::TestCase
  setup do
    @kapa_report = kapa_reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_report" do
    assert_difference('Kapa::Report.count') do
      post :create, kapa_report: {  }
    end

    assert_redirected_to kapa_report_path(assigns(:kapa_report))
  end

  test "should show kapa_report" do
    get :show, id: @kapa_report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_report
    assert_response :success
  end

  test "should update kapa_report" do
    patch :update, id: @kapa_report, kapa_report: {  }
    assert_redirected_to kapa_report_path(assigns(:kapa_report))
  end

  test "should destroy kapa_report" do
    assert_difference('Kapa::Report.count', -1) do
      delete :destroy, id: @kapa_report
    end

    assert_redirected_to kapa_reports_path
  end
end
