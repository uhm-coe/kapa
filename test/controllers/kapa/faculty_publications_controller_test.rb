require 'test_helper'

class Kapa::FacultyPublicationsControllerTest < ActionController::TestCase
  setup do
    @kapa_faculty_publication = kapa_faculty_publications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_faculty_publications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_faculty_publication" do
    assert_difference('Kapa::FacultyPublication.count') do
      post :create, kapa_faculty_publication: {  }
    end

    assert_redirected_to kapa_faculty_publication_path(assigns(:kapa_faculty_publication))
  end

  test "should show kapa_faculty_publication" do
    get :show, id: @kapa_faculty_publication
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_faculty_publication
    assert_response :success
  end

  test "should update kapa_faculty_publication" do
    patch :update, id: @kapa_faculty_publication, kapa_faculty_publication: {  }
    assert_redirected_to kapa_faculty_publication_path(assigns(:kapa_faculty_publication))
  end

  test "should destroy kapa_faculty_publication" do
    assert_difference('Kapa::FacultyPublication.count', -1) do
      delete :destroy, id: @kapa_faculty_publication
    end

    assert_redirected_to kapa_faculty_publications_path
  end
end
