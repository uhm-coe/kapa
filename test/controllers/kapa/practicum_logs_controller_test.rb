require 'test_helper'

class Kapa::PracticumLogsControllerTest < ActionController::TestCase
  setup do
    @kapa_practicum_log = kapa_practicum_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_practicum_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_practicum_log" do
    assert_difference('Kapa::PracticumLog.count') do
      post :create, kapa_practicum_log: {  }
    end

    assert_redirected_to kapa_practicum_log_path(assigns(:kapa_practicum_log))
  end

  test "should show kapa_practicum_log" do
    get :show, id: @kapa_practicum_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_practicum_log
    assert_response :success
  end

  test "should update kapa_practicum_log" do
    patch :update, id: @kapa_practicum_log, kapa_practicum_log: {  }
    assert_redirected_to kapa_practicum_log_path(assigns(:kapa_practicum_log))
  end

  test "should destroy kapa_practicum_log" do
    assert_difference('Kapa::PracticumLog.count', -1) do
      delete :destroy, id: @kapa_practicum_log
    end

    assert_redirected_to kapa_practicum_logs_path
  end
end
