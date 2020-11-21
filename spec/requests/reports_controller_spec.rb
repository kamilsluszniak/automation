# frozen_string_literal: true

require 'rails_helper'
require 'helpers/reports_helpers'

RSpec.describe Api::V1::ReportsController, type: :request do
  context 'when device is created' do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }
    let(:aquarium_controller) { create(:aquarium_controller, user: user) }
    let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

    it 'not update Device measurements on CREATE without an access token' do
      post '/api/v1/reports', params: { device: { name: device.name, authentication_token: nil } }
      expect(response).to have_http_status(401)
    end

    it 'updates Device measurements on CREATE with an access token' do
      body = {
        device: {
          name: device.name, reports: {
            test: 1
          }
        }
      }

      post '/api/v1/reports', params: body.to_json, headers: auth_headers

      expect(response).to have_http_status(200)
      resp = JSON.parse(response.body)
      expect(resp).to have_key('settings')
    end

    it 'returns connected device with settings after report' do
      body = {
        device: {
          name: aquarium_controller.name,
          reports: {
            dummy_report: 666
          }
        }
      }

      post '/api/v1/reports', params: body.to_json, headers: auth_headers

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['settings']['connected_devices']['water_input_valve']).to eq '192.168.2.108'
    end
  end
end
