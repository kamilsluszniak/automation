# frozen_string_literal: true

class AddActiveToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :active, :boolean, default: false
  end
end
