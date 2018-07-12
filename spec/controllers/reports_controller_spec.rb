
require 'rails_helper'
require 'helpers/reports_helpers'

RSpec.describe ReportsController, type: :controller do

  context "when device is created" do
    let(:device) { create(:device) }


    it "not update Device measurements on CRREATE without an access token" do
      post :create, params: {:id => device.name, :device => {:authentication_token => nil} }
      expect(response).to have_http_status(401)
    end

    it "updates Device measurements on CREATE with an access token" do
      expect{ post :create, params: {:id => device.name, :device => {:authentication_token => device.authentication_token, :reports => {:test => 1} } } }.to change{test_metric_count}.by(1)
      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to have_key("authentication_token")
    end

    it "redirects SHOW when user not signed in" do
      get :show, params: {:id => device.name }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "gets Device measurements on SHOW when user signed in" do
      get :show, params: {:id => device.name, :device => {:authentication_token => device.authentication_token, :reports => {:test => 1} } }
      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to have_key("authentication_token")
    end
  end
end
