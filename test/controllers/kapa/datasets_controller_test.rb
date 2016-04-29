require 'test_helper'

class Kapa::DatasetsControllerTest < ActionController::TestCase
  setup do
    @kapa_dataset = kapa_datasets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_datasets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_dataset" do
    assert_difference('Kapa::Dataset.count') do
      post :create, kapa_dataset: {  }
    end

    assert_redirected_to kapa_dataset_path(assigns(:kapa_dataset))
  end

  test "should show kapa_dataset" do
    get :show, id: @kapa_dataset
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_dataset
    assert_response :success
  end

  test "should update kapa_dataset" do
    patch :update, id: @kapa_dataset, kapa_dataset: {  }
    assert_redirected_to kapa_dataset_path(assigns(:kapa_dataset))
  end

  test "should destroy kapa_dataset" do
    assert_difference('Kapa::Dataset.count', -1) do
      delete :destroy, id: @kapa_dataset
    end

    assert_redirected_to kapa_datasets_path
  end
end
