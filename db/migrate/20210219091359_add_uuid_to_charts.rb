# frozen_string_literal: true

class AddUuidToCharts < ActiveRecord::Migration[6.0]
  def up
    add_column :charts, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :charts, :id, :integer_id
    rename_column :charts, :uuid, :id

    execute 'ALTER TABLE charts drop constraint charts_pkey;'
    execute 'ALTER TABLE charts ADD PRIMARY KEY (id);'

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY charts ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :charts, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS charts_id_seq'
    remove_column :charts, :integer_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
