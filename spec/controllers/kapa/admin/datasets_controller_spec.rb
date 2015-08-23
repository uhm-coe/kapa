require 'spec_helper.rb'

describe Kapa::DatasetsController, type: :controller do
  render_views
  let(:user){FactoryGirl.create(:user)}

  describe "GET index" do

    context "not signed in" do
      it "redirects to main page" do
        get :index, kapa_admin_datasets_path
        expect(response.body).to include(new_kapa_main_session_path)
        puts "#{response.body}"
      end
    end

    context "signed in" do
      it "shows index page" do
        allow(controller).to receive(:validate_login){user.request = request; @current_user = user}
        allow(controller).to receive(:check_read_permission)
        get :index, kapa_admin_datasets_path
        expect(response.body).to include('Datasets')
        expect(response.status).to be(200)
      end
    end

  end

  describe "POST create" do

    context "signed in" do

    it 'creates a dataset' do
      allow(controller).to receive(:validate_login){user.request = request; @current_user = user}
      allow(controller).to receive(:check_read_permission)
      allow(controller).to receive(:check_write_permission)
      params = {:dataset => { name: 'dataset1', type: 'type1', description: 'desc' }}
      #(:name, :type, :datasource, :description, :query, :ldap_base, :ldap_filter, :ldap_attr, :file)
      expect(Kapa::Dataset).to receive(:new).with(params.with_indifferent_access[:dataset]).
                                   and_return(Kapa::Dataset.new(params.with_indifferent_access[:dataset]))
      expect{post :create, kapa_admin_datasets_path, params}.to change{Kapa::Dataset.count}.by(1)
      expect(response.code).to eq('302')
    end

    end
  end

end

