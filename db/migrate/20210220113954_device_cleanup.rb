# frozen_string_literal: true

class DeviceCleanup < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/AbcSize
  def change
    # rubocop:disable Rails/BulkChangeTable
    remove_column(:devices, :type, :string)
    remove_column(:devices, :encrypted_password, :string)
    remove_column(:devices, :reset_password_token, :string)
    remove_column(:devices, :reset_password_sent_at, :datetime)
    remove_column(:devices, :remember_created_at, :datetime)
    remove_column(:devices, :sign_in_count, :integer)
    remove_column(:devices, :current_sign_in_at, :datetime)
    remove_column(:devices, :last_sign_in_at, :datetime)
    remove_column(:devices, :current_sign_in_ip, :inet)
    remove_column(:devices, :last_sign_in_ip, :inet)
    remove_column(:devices, :authentication_token, :string)
    remove_column(:devices, :authentication_token_created_at, :datetime)
    remove_column(:devices, :turn_on_time, :integer)
    remove_column(:devices, :turn_off_time, :integer)
    remove_column(:devices, :intensity, :string)
    remove_column(:devices, :on_temperature, :integer)
    remove_column(:devices, :off_temperature, :integer)
    remove_column(:devices, :on_volume, :integer)
    remove_column(:devices, :off_volume, :integer)
    remove_column(:devices, :group, :string)
    remove_column(:devices, :temperature_set, :decimal)
    remove_column(:devices, :status, :string)
    remove_column(:devices, :on, :boolean)
    remove_column(:devices, :temperature, :decimal)
    remove_column(:devices, :distance, :decimal)
    remove_column(:devices, :intensity_override, :string)
    remove_column(:devices, :co2valve_on_time, :integer)
    remove_column(:devices, :co2valve_off_time, :integer)
    remove_column(:devices, :light_intensity_lvl, :float)
    remove_column(:devices, :water_input_valve_on, :boolean)
    # rubocop:enable Rails/BulkChangeTable
  end
  # rubocop:enable Metrics/AbcSize
end
