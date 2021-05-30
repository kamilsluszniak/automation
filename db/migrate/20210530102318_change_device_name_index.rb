# frozen_string_literal: true

class ChangeDeviceNameIndex < ActiveRecord::Migration[6.0]
  def up
    remove_index :devices, name: 'index_devices_on_name'
    add_index :devices, %i[user_id name], unique: true
  end

  def down
    add_index :devices, :name, unique: true
    remove_index :devices, name: 'index_devices_on_user_id_and_name'
  end
end
