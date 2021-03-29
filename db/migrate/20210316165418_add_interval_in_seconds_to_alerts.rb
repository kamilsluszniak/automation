# frozen_string_literal: true

class AddIntervalInSecondsToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :interval_in_seconds, :integer, default: 1800
  end
end
