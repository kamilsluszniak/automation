# frozen_string_literal: true

class AddUuidToAlerts < ActiveRecord::Migration[6.0]
  def up
    add_column :alerts, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    remove_foreign_key :alerts_triggers, column: :alert_id
    rename_column :alerts, :id, :integer_id
    rename_column :alerts, :uuid, :id

    execute 'ALTER TABLE alerts drop constraint alerts_pkey;'
    execute 'ALTER TABLE alerts ADD PRIMARY KEY (id);'

    remove_column :alerts_triggers, :alert_id

    add_reference :alerts_triggers, :alert, type: :uuid, index: true
    add_foreign_key :alerts_triggers, :alerts
    change_column_null :alerts_triggers, :alert_id, false

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY alerts ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :alerts, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS alerts_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
