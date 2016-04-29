require 'test_helper'

class Kapa::ProgramsControllerTest < ActionController::TestCase
  setup do
    @kapa_program = kapa_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_program" do
    assert_difference('Kapa::Program.count') do
      post :create, kapa_program: {  }
    end

    assert_redirected_to kapa_program_path(assigns(:kapa_program))
  end

  test "should show kapa_program" do
    get :show, id: @kapa_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_program
    assert_response :success
  end

  test "should update kapa_program" do
    patch :update, id: @kapa_program, kapa_program: {  }
    assert_redirected_to kapa_program_path(assigns(:kapa_program))
  end

  test "should destroy kapa_program" do
    assert_difference('Kapa::Program.count', -1) do
      delete :destroy, id: @kapa_program
    end

    assert_redirected_to kapa_programs_path
  end
end
