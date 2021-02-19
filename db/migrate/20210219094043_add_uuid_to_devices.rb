# frozen_string_literal: true

class AddUuidToDevices < ActiveRecord::Migration[6.0]
  def up
    add_column :devices, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    remove_foreign_key :charts, column: :device_id
    rename_column :devices, :id, :integer_id
    rename_column :devices, :uuid, :id

    execute 'ALTER TABLE devices drop constraint devices_pkey;'
    execute 'ALTER TABLE devices ADD PRIMARY KEY (id);'

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY devices ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :devices, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS devices_id_seq'
    remove_column :devices, :integer_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
