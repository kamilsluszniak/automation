# frozen_string_literal: true

class DeviceSerializer
  include FastJsonapi::ObjectSerializer
  attribute :settings, if: Proc.new { |record, params|
    params&.dig(:current_settings) != 'true'
  }

  attribute :current_settings, if: Proc.new { |record, params|
    params&.dig(:current_settings) == 'true'
  } do |device|
    Devices::SettingsInterpreter.new(device.settings).call
  end
end
