# frozen_string_literal: true

class AddUuidToUsers < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def up
    add_column :users, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    remove_foreign_key :alerts, column: :user_id
    remove_foreign_key :api_keys, column: :user_id
    remove_foreign_key :charts, column: :user_id
    remove_foreign_key :triggers, column: :user_id
    remove_foreign_key :devices, column: :user_id
    rename_column :users, :id, :integer_id
    rename_column :users, :uuid, :id
    execute 'ALTER TABLE users drop constraint users_pkey;'
    execute 'ALTER TABLE users ADD PRIMARY KEY (id);'

    add_column :devices, :user_old_id, :integer
    Device.all.each do |device|
      device.user_old_id = device.user_id
    end

    add_column :alerts, :user_old_id, :integer
    Alert.all.each do |alert|
      alert.user_old_id = alert.user_id
    end

    add_column :triggers, :user_old_id, :integer
    Trigger.all.each do |trigger|
      trigger.user_old_id = trigger.user_id
    end

    remove_column :alerts, :user_id
    remove_column :api_keys, :user_id
    remove_column :charts, :user_id
    remove_column :triggers, :user_id
    remove_column :devices, :user_id

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY users ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :users, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS users_id_seq'
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
