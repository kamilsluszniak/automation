# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :request do
  context 'when device is created' do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }

    # it 'gets light device settings' do
    #   Timecop.freeze(Time.zone.now) do
    #     get "/api/v1/devices/#{device.name}"
    #     data = JSON.parse(response.body)
    #     settings = data.dig(:data, :attributes, :settings)
    #     binding.pry
    #     intensity_hash = { 'red' => 10, 'green' => 40, 'blue' => 0, 'white' => 10 }
    #     assert_equal 3.hours.ago.to_i, settings['turn_on_time']
    #     assert_equal 4.hours.from_now.to_i, settings['turn_off_time']
    #     assert_equal intensity_hash, settings['intensity']
    #     assert_equal true, settings['on']
    #   end
    # end

    # it 'updates settings and send it to device' do
    #   patch :update, params: { id: device.name, device: { turn_on_time: Time.zone.now } }

    #   expect(response).to redirect_to device_path(device.id)
    # end
  end
end
