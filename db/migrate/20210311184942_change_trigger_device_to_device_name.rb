# frozen_string_literal: true

class ChangeTriggerDeviceToDeviceName < ActiveRecord::Migration[6.0]
  def change
    rename_column :triggers, :device, :device_name
  end
end
