# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MeasurementsController, type: :request do
  context 'when device is created' do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:trigger) do
      create(
        :trigger,
        user: user,
        alerts: alerts,
        device: device,
        dependencies: dependencies,
        enabled: true,
        value: 10,
        operator: parent_trigger_operator
      )
    end
    let(:parent_trigger_operator) { '<' }

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
              name: trigger.device.name,
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
          expect(resp['message']).to eq('success')
        end
      end

      context 'when trigger gets triggered' do
        let(:metric_value) { 1 }

        it 'updates Device measurements on CREATE and triggers the trigger' do
          body = {
            device: {
              name: trigger.device.name,
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
          expect(resp['message']).to eq('success')
        end
      end

      context 'when trigger doesn`t get triggered' do
        let(:metric_value) { 11 }

        it 'updates Device measurements on CREATE and triggers the trigger' do
          body = {
            device: {
              name: trigger.device.name,
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
          expect(resp['message']).to eq('success')
        end
      end

      context 'when trigger has child triggers' do
        let(:alerts2) { create_list(:alert, 2, user: user) }
        let(:alerts3) { create_list(:alert, 2, user: user) }
        let(:device2) { create(:device, user: user, name: 'sensor2') }
        let(:device3) { create(:device, user: user, name: 'sensor3') }

        let!(:trigger2) do
          create(
            :trigger,
            user: user,
            alerts: alerts2,
            metric: 'sensor2_metric',
            device: device2,
            operator: '>',
            value: 5,
            parent: trigger,
            enabled: true
          )
        end
        let!(:trigger3) do
          create(
            :trigger,
            user: user,
            alerts: alerts3,
            metric: 'sensor3_metric',
            device: device3,
            operator: '>',
            value: 5,
            parent: trigger,
            enabled: true
          )
        end

        let(:metric_value) { 11 }

        context 'when trigger has `AND` operator' do
          let(:parent_trigger_operator) { 'AND' }
          let(:measurements) do
            [
              {
                name: trigger3.metric,
                value: 11
              }
            ]
          end
          let(:body) do
            {
              device: {
                name: trigger2.device.name,
                measurements: {
                  trigger2.metric => metric_value
                }
              }
            }
          end

          it 'not triggers parent trigger when not all childs are triggered' do
            expect do
              post '/api/v1/measurements', params: body.to_json, headers: headers
            end.to change {
              ActionMailer::Base.deliveries.count
            }.by(0)

            expect(response).to have_http_status(200)
            resp = JSON.parse(response.body)
            expect(resp['message']).to eq('success')
          end

          it 'triggers parent trigger when all childs are triggered' do
            Measurements::Writer.new(
              device_id: trigger3.device_id, user_id: user.id
            ).call(measurements)

            expect do
              post '/api/v1/measurements', params: body.to_json, headers: headers
            end.to change {
              ActionMailer::Base.deliveries.count
            }.by(2)

            expect(response).to have_http_status(200)
            resp = JSON.parse(response.body)
            expect(resp['message']).to eq('success')
          end
        end
      end
    end
  end
end
