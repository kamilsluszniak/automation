
require 'rails_helper'
require 'helpers/reports_helpers'

RSpec.describe ReportsController, type: :controller do

  context "when device is created" do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }
    let(:aquarium_controller) { create(:aquarium_controller, user: user) }
    let(:valve_controller) { create(:valve_controller, user: user, aquarium_controller: aquarium_controller) }

    it "not update Device measurements on CRREATE without an access token" do
      post :create, params: {:device => {:name => device.name, :authentication_token => nil} }
      expect(response).to have_http_status(401)
    end

    it "updates Device measurements on CREATE with an access token" do
      headers = { 'HTTP_AUTHORIZATION' => device.authentication_token }
      request.headers.merge! headers
      post :create, params: {
        :device => {
          :name => device.name, :reports => {
            :test => 1
          }
        }
      }

      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to have_key("settings")
    end

    it "redirects SHOW when user not signed in" do
      get :show, params: {:device => {:name => device.name } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "gets Device measurements on SHOW when user signed in" do
      login_with user
      get :show, params: {:device => {:name => device.name, :authentication_token => device.authentication_token, :reports => {:name => "test"} } }
      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to be_instance_of(Array)
    end

    it "sets valve on when reporting aquarium controller measurements on CREATE with an access token and when distance goes down sets it off" do
      expect(valve_controller.on).to be_falsey
      headers = { 'HTTP_AUTHORIZATION' => aquarium_controller.authentication_token }
      request.headers.merge! headers

      post :create, params: {
        :device => {
          :name => aquarium_controller.name, :reports => {
            :distance => 201
          }
        }
      }

      expect(response).to have_http_status(200)
      expect(valve_controller.reload.on).to be_truthy

      post :create, params: {
        :device => {
          :name => aquarium_controller.name, :reports => {
            :distance => 199
          }
        }
      }
      expect(response).to have_http_status(200)
      expect(valve_controller.reload.on).to be_falsey

    end

  end
end
