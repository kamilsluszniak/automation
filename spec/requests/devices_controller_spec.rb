# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DevicesController, type: :request do
  describe '#show' do
    context 'when device is created' do
      let(:user) { create(:user) }
      let(:device) { create(:device, user: user) }

      it 'returns serialized settings' do
        get "/api/v1/devices/#{device.name}"
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
        get "/api/v1/devices/#{device.name}", params: { current_settings: true }
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
