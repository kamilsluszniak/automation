# frozen_string_literal: true

class AddForeignKeysOfUserId < ActiveRecord::Migration[6.0]
  def up
    add_reference :alerts, :user, type: :uuid, index: true
    add_reference :api_keys, :user, type: :uuid, index: true
    add_reference :charts, :user, type: :uuid, index: true
    add_reference :triggers, :user, type: :uuid, index: true
    add_reference :devices, :user, type: :uuid, index: true

    add_foreign_key :alerts, :users
    add_foreign_key :api_keys, :users
    add_foreign_key :charts, :users
    add_foreign_key :triggers, :users
    add_foreign_key :devices, :users

    # Device.all.each do |device|
    #   u = User.find_by(integer_id: device.user_old_id)
    #   device.user_id = u.id
    #   device.save
    # end

    # Alert.all.each do |alert|
    #   u = User.find_by(integer_id: alert.user_old_id)
    #   alert.user_id = u.id
    #   alert.save
    # end

    # Trigger.all.each do |trigger|
    #   u = User.find_by(integer_id: trigger.user_old_id)
    #   trigger.user_id = u.id
    #   trigger.save
    # end

    # ApiKey.all.each do |key|
    #   u = User.find_by(integer_id: key.user_old_id)
    #   key.user_id = u.id
    #   key.save
    # end

    # change_column_null :alerts, :user_id, false
    # change_column_null :api_keys, :user_id, false
    # change_column_null :charts, :user_id, false
    # change_column_null :triggers, :user_id, false
    # change_column_null :devices, :user_id, false

    # remove_column :devices, :user_old_id
    # remove_column :alerts, :user_old_id
    # remove_column :triggers, :user_old_id
    # remove_column :api_keys, :user_old_id
  end

  def down
    change_column_null :alerts, :user_id, true
    change_column_null :api_keys, :user_id, true
    change_column_null :charts, :user_id, true
    change_column_null :triggers, :user_id, true
    change_column_null :devices, :user_id, true

    remove_foreign_key :alerts, column: :user_id
    remove_foreign_key :api_keys, column: :user_id
    remove_foreign_key :charts, column: :user_id
    remove_foreign_key :triggers, column: :user_id
    remove_foreign_key :devices, column: :user_id

    remove_column :alerts, :user_id
    remove_column :api_keys, :user_id
    remove_column :charts, :user_id
    remove_column :triggers, :user_id
    remove_column :devices, :user_id
  end
end
