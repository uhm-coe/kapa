require 'test_helper'

class Kapa::PracticumSitesControllerTest < ActionController::TestCase
  setup do
    @kapa_practicum_site = kapa_practicum_sites(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_practicum_sites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_practicum_site" do
    assert_difference('Kapa::PracticumSite.count') do
      post :create, kapa_practicum_site: {  }
    end

    assert_redirected_to kapa_practicum_site_path(assigns(:kapa_practicum_site))
  end

  test "should show kapa_practicum_site" do
    get :show, id: @kapa_practicum_site
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_practicum_site
    assert_response :success
  end

  test "should update kapa_practicum_site" do
    patch :update, id: @kapa_practicum_site, kapa_practicum_site: {  }
    assert_redirected_to kapa_practicum_site_path(assigns(:kapa_practicum_site))
  end

  test "should destroy kapa_practicum_site" do
    assert_difference('Kapa::PracticumSite.count', -1) do
      delete :destroy, id: @kapa_practicum_site
    end

    assert_redirected_to kapa_practicum_sites_path
  end
end
