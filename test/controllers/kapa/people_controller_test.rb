require 'test_helper'

class Kapa::PeopleControllerTest < ActionController::TestCase
  setup do
    @kapa_person = kapa_people(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_person" do
    assert_difference('Kapa::Person.count') do
      post :create, kapa_person: {  }
    end

    assert_redirected_to kapa_person_path(assigns(:kapa_person))
  end

  test "should show kapa_person" do
    get :show, id: @kapa_person
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_person
    assert_response :success
  end

  test "should update kapa_person" do
    patch :update, id: @kapa_person, kapa_person: {  }
    assert_redirected_to kapa_person_path(assigns(:kapa_person))
  end

  test "should destroy kapa_person" do
    assert_difference('Kapa::Person.count', -1) do
      delete :destroy, id: @kapa_person
    end

    assert_redirected_to kapa_people_path
  end
end
