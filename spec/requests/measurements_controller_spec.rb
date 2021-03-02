# frozen_string_literal: true

require 'rails_helper'
require 'helpers/reports_helpers'

RSpec.describe Api::V1::MeasurementsController, type: :request do
  context 'when device is created' do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: alerts, device: device.name, dependencies: dependencies) }

    let(:headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Api-Key' => api_key&.key
      }
    end

    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

    let(:device_settings) do
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
      }
    end

    context 'when no api token or key is present' do
      it 'not update Device measurements on CREATE without an access token' do
        post '/api/v1/measurements', params: { device: { name: device.name } }
        expect(response).to have_http_status(401)
      end
    end

    context 'when API key is present' do
      let(:api_key) { create(:api_key, user: user) }

      let(:dependencies) do
        {
          devices: {
            dependent_device: {
              triggered: {
                on: true
              },
              not_triggered: {
                on: false
              }
            }
          }
        }
      end

      let(:device) { create(:device, name: 'dependent_device', user: user) }

      context 'when measurements are string' do
        let(:metric_value) { '4' }

        it 'updates Device measurements on CREATE and triggers the trigger' do
          body = {
            device: {
              name: trigger.device,
              measurements: {
                trigger.metric => metric_value
              }
            }
          }

          expect(device.settings).to eq(device_settings)

          expect do
            post '/api/v1/measurements', params: body.to_json, headers: headers
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(2)

          expect(device.reload.settings).to eq('on' => true)

          expect(response).to have_http_status(200)
          resp = JSON.parse(response.body)
          expect(resp).to have_key('message')
        end
      end

      context 'when trigger gets triggered' do
        let(:metric_value) { 1 }

        it 'updates Device measurements on CREATE and triggers the trigger' do
          body = {
            device: {
              name: trigger.device,
              measurements: {
                trigger.metric => metric_value
              }
            }
          }

          expect(device.settings).to eq(device_settings)

          expect do
            post '/api/v1/measurements', params: body.to_json, headers: headers
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(2)

          expect(device.reload.settings).to eq('on' => true)

          expect(response).to have_http_status(200)
          resp = JSON.parse(response.body)
          expect(resp).to have_key('message')
        end
      end

      context 'when trigger doesn`t get triggered' do
        let(:metric_value) { 11 }

        it 'updates Device measurements on CREATE and triggers the trigger' do
          body = {
            device: {
              name: trigger.device,
              measurements: {
                trigger.metric => metric_value
              }
            }
          }

          expect(device.settings).to eq(device_settings)

          expect do
            post '/api/v1/measurements', params: body.to_json, headers: headers
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(0)

          expect(device.reload.settings).to eq('on' => false)

          expect(response).to have_http_status(200)
          resp = JSON.parse(response.body)
          expect(resp).to have_key('message')
        end
      end
    end
  end
end
