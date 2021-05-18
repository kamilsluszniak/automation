# frozen_string_literal: true

class AddTimeZoneToDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :time_zone, :string, default: 'UTC'
  end
end
