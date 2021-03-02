# frozen_string_literal: true

class AddEnabledToTriggers < ActiveRecord::Migration[6.0]
  def change
    add_column :triggers, :enabled, :boolean, default: false
  end
end
