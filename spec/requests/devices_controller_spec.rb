# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DevicesController, type: :request do
  describe '#show' do
    context 'when device is created' do
      let(:user) { create(:user) }
      let(:device) { create(:device, user: user) }
      let(:headers) do
        {
          'Api-Key' => api_key&.key
        }
      end

      context 'when api key is present' do
        let(:api_key) { create(:api_key, user: user) }

        it 'returns serialized settings' do
          get "/api/v1/devices/#{device.name}", headers: headers
          data = JSON.parse(response.body)
          settings = data.dig('data', 'attributes', 'settings')
          expect(settings).to eq(
            {
              light_intensity: {
                time_dependent: true,
                override: {
                  red: 100,
                  green: 400
                },
                values: {
                  600 => {
                    red: 10,
                    green: 40
                  },
                  700 => {
                    red: 20,
                    green: 50
                  },
                  800 => {
                    red: 0,
                    green: 0
                  }
                }
              },
              water_height: 300
            }.deep_stringify_keys
          )
        end

        it 'returns serialized settings' do
          get "/api/v1/devices/#{device.name}", params: { current_settings: true },
                                                headers: headers
          data = JSON.parse(response.body)
          settings = data.dig('data', 'attributes', 'current_settings')
          expect(settings).to eq(
            {
              light_intensity: {
                red: 100,
                green: 400
              },
              water_height: 300
            }.deep_stringify_keys
          )
        end
      end

      context 'when api key is not present' do
        it 'returns unauthorized' do
          get "/api/v1/devices/#{device.name}"
          expect(response.status).to eq(401)
        end
      end

      context 'when authorization header is present' do
        let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

        it 'returns serialized settings' do
          get "/api/v1/devices/#{device.name}", params: { current_settings: true },
                                                headers: auth_headers
          data = JSON.parse(response.body)
          settings = data.dig('data', 'attributes', 'current_settings')
          expect(settings).to eq(
            {
              light_intensity: {
                red: 100,
                green: 400
              },
              water_height: 300
            }.deep_stringify_keys
          )
        end
      end
    end
  end
end
