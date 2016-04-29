require 'test_helper'

class Kapa::FilesControllerTest < ActionController::TestCase
  setup do
    @kapa_file = kapa_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_file" do
    assert_difference('Kapa::File.count') do
      post :create, kapa_file: {  }
    end

    assert_redirected_to kapa_file_path(assigns(:kapa_file))
  end

  test "should show kapa_file" do
    get :show, id: @kapa_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_file
    assert_response :success
  end

  test "should update kapa_file" do
    patch :update, id: @kapa_file, kapa_file: {  }
    assert_redirected_to kapa_file_path(assigns(:kapa_file))
  end

  test "should destroy kapa_file" do
    assert_difference('Kapa::File.count', -1) do
      delete :destroy, id: @kapa_file
    end

    assert_redirected_to kapa_files_path
  end
end
