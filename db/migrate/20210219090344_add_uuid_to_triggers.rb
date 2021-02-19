# frozen_string_literal: true

class AddUuidToTriggers < ActiveRecord::Migration[6.0]
  def up
    add_column :triggers, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    remove_foreign_key :alerts_triggers, column: :trigger_id
    rename_column :triggers, :id, :integer_id
    rename_column :triggers, :uuid, :id

    execute 'ALTER TABLE triggers drop constraint triggers_pkey;'
    execute 'ALTER TABLE triggers ADD PRIMARY KEY (id);'

    remove_column :alerts_triggers, :trigger_id

    add_reference :alerts_triggers, :trigger, type: :uuid, index: true
    add_foreign_key :alerts_triggers, :triggers
    change_column_null :alerts_triggers, :trigger_id, false

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY triggers ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :triggers, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS triggers_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
