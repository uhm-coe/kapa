require 'test_helper'

class Kapa::TermsControllerTest < ActionController::TestCase
  setup do
    @kapa_term = kapa_terms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_terms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_term" do
    assert_difference('Kapa::Term.count') do
      post :create, kapa_term: {  }
    end

    assert_redirected_to kapa_term_path(assigns(:kapa_term))
  end

  test "should show kapa_term" do
    get :show, id: @kapa_term
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_term
    assert_response :success
  end

  test "should update kapa_term" do
    patch :update, id: @kapa_term, kapa_term: {  }
    assert_redirected_to kapa_term_path(assigns(:kapa_term))
  end

  test "should destroy kapa_term" do
    assert_difference('Kapa::Term.count', -1) do
      delete :destroy, id: @kapa_term
    end

    assert_redirected_to kapa_terms_path
  end
end
