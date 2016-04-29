require 'test_helper'

class Kapa::ProgramOffersControllerTest < ActionController::TestCase
  setup do
    @kapa_program_offer = kapa_program_offers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kapa_program_offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kapa_program_offer" do
    assert_difference('Kapa::ProgramOffer.count') do
      post :create, kapa_program_offer: {  }
    end

    assert_redirected_to kapa_program_offer_path(assigns(:kapa_program_offer))
  end

  test "should show kapa_program_offer" do
    get :show, id: @kapa_program_offer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kapa_program_offer
    assert_response :success
  end

  test "should update kapa_program_offer" do
    patch :update, id: @kapa_program_offer, kapa_program_offer: {  }
    assert_redirected_to kapa_program_offer_path(assigns(:kapa_program_offer))
  end

  test "should destroy kapa_program_offer" do
    assert_difference('Kapa::ProgramOffer.count', -1) do
      delete :destroy, id: @kapa_program_offer
    end

    assert_redirected_to kapa_program_offers_path
  end
end
