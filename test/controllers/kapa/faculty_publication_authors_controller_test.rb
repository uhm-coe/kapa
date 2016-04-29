require 'test_helper'

class Kapa::FacultyPublicationAuthorsControllerTest < ActionController::TestCase
  setup do
    @kapa_faculty_publication_author = kapa_faculty_publication_authors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_faculty_publication_authors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_faculty_publication_author" do
    assert_difference('Kapa::FacultyPublicationAuthor.count') do
      post :create, kapa_faculty_publication_author: {  }
    end

    assert_redirected_to kapa_faculty_publication_author_path(assigns(:kapa_faculty_publication_author))
  end

  test "should show kapa_faculty_publication_author" do
    get :show, id: @kapa_faculty_publication_author
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_faculty_publication_author
    assert_response :success
  end

  test "should update kapa_faculty_publication_author" do
    patch :update, id: @kapa_faculty_publication_author, kapa_faculty_publication_author: {  }
    assert_redirected_to kapa_faculty_publication_author_path(assigns(:kapa_faculty_publication_author))
  end

  test "should destroy kapa_faculty_publication_author" do
    assert_difference('Kapa::FacultyPublicationAuthor.count', -1) do
      delete :destroy, id: @kapa_faculty_publication_author
    end

    assert_redirected_to kapa_faculty_publication_authors_path
  end
end
