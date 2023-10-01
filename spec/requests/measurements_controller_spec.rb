# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MeasurementsController, type: :request do
  context 'when device is created' do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:triggers_checker_queue_publisher_instance) { instance_double(Triggers::CheckerQueuePublisher) }
    let(:measurements_writer_instance) { instance_double(Measurements::Writer) }
    let(:trigger) do
      create(
        :trigger,
        user: user,
        alerts: alerts,
        device: device,
        dependencies: nil,
        enabled: true,
        value: 10,
      )
    end
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
        post '/api/v1/measurements', params: { device: { name: device.name } }
        expect(response).to have_http_status(401)
      end
    end

    context 'when API key is present' do
      let(:api_key) { create(:api_key, user: user) }

      context 'when no triggers and alerts exist' do
        let(:device) { create(:device, user: user, name: 'bulbulator') }
        let(:post_data) {
          {
            device: {
              name: device.name,
              measurements: {
                't0' => '40.25',
                't1' => '29.00'
              }
            }
          }.to_json
        }

        it 'not raises an error' do
          expect(Measurements::Writer).to receive(:new).with(device_id: device.id, user_id: user.id).and_return(measurements_writer_instance)
          expect(measurements_writer_instance).to receive(:call).with(
            [
              {:name=>"t0", :value=>"40.25"}, {:name=>"t1", :value=>"29.00"}
            ]
          ).and_return(OpenStruct.new(code: '204'))
          expect(Triggers::CheckerQueuePublisher).to receive(:new).with(user_id: user.id).and_return(triggers_checker_queue_publisher_instance)
          expect(triggers_checker_queue_publisher_instance).to receive(:publish)

          post '/api/v1/measurements', params: post_data, headers: headers
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
