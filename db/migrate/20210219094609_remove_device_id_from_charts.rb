# frozen_string_literal: true

class RemoveDeviceIdFromCharts < ActiveRecord::Migration[6.0]
  def up
    remove_column :charts, :device_id
  end
end
