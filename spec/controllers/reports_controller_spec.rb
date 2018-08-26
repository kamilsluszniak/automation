
require 'rails_helper'
require 'helpers/reports_helpers'

RSpec.describe ReportsController, type: :controller do

  context "when device is created" do
    let(:device) { create(:device) }

    it "not update Device measurements on CRREATE without an access token" do
      post :create, params: {:device => {:name => device.name, :authentication_token => nil} }
      expect(response).to have_http_status(401)
    end

    it "updates Device measurements on CREATE with an access token" do
      count = test_metric_count
      post :create, params: {
        :device => {
          :name => device.name, :authentication_token => device.authentication_token, :reports => {
            :test => 1
          }
        }
      }
      expect(count).to eq(test_metric_count - 1)

      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to have_key("authentication_token")
      expect(resp).to have_key("settings")
    end

    it "redirects SHOW when user not signed in" do
      get :show, params: {:device => {:name => device.name } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "gets Device measurements on SHOW when user signed in" do
      user = create(:user)
      login_with user
      get :show, params: {:device => {:name => device.name, :authentication_token => device.authentication_token, :reports => {:name => "test"} } }
      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to be_instance_of(Array)
    end
  end
end
