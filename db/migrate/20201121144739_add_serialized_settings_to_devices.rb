# frozen_string_literal: true

class AddSerializedSettingsToDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :settings, :string
  end
end
