# frozen_string_literal: true

require 'rails_helper'
require 'helpers/reports_helpers'

RSpec.describe Api::V1::ReportsController, type: :request do
  context 'when device is created' do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }

    let(:headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Api-Key' => api_key&.key
      }
    end

    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

    context 'when no api token or key is present' do
      it 'not update Device measurements on CREATE without an access token' do
        post '/api/v1/reports', params: { device: { name: device.name } }
        expect(response).to have_http_status(401)
      end
    end

    context 'when API key is present' do
      let(:api_key) { create(:api_key, user: user) }

      it 'updates Device measurements on CREATE with an api key' do
        body = {
          device: {
            name: device.name,
            reports: {
              test: 1
            }
          }
        }

        post '/api/v1/reports', params: body.to_json, headers: headers

        expect(response).to have_http_status(200)
        resp = JSON.parse(response.body)
        expect(resp).to have_key('message')
      end
    end
  end
end
