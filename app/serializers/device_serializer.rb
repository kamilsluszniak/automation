# frozen_string_literal: true

class DeviceSerializer
  include FastJsonapi::ObjectSerializer
  attribute :settings, if: proc { |_record, params|
    params&.dig(:current_settings) != 'true'
  }

  attribute :current_settings, if: proc { |_record, params|
    params&.dig(:current_settings) == 'true'
  } do |device|
    Devices::SettingsInterpreter.new(device.settings).call
  end
end
