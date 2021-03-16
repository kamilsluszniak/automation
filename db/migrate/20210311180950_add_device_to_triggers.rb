# frozen_string_literal: true

class AddDeviceToTriggers < ActiveRecord::Migration[6.0]
  def change
    add_reference :triggers, :device, foreign_key: true, index: true, type: :uuid
  end
end
