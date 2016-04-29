require 'test_helper'

class Kapa::PropertiesControllerTest < ActionController::TestCase
  setup do
    @kapa_property = kapa_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_property" do
    assert_difference('Kapa::Property.count') do
      post :create, kapa_property: {  }
    end

    assert_redirected_to kapa_property_path(assigns(:kapa_property))
  end

  test "should show kapa_property" do
    get :show, id: @kapa_property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_property
    assert_response :success
  end

  test "should update kapa_property" do
    patch :update, id: @kapa_property, kapa_property: {  }
    assert_redirected_to kapa_property_path(assigns(:kapa_property))
  end

  test "should destroy kapa_property" do
    assert_difference('Kapa::Property.count', -1) do
      delete :destroy, id: @kapa_property
    end

    assert_redirected_to kapa_properties_path
  end
end
