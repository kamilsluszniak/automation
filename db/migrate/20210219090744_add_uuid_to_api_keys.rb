# frozen_string_literal: true

class AddUuidToApiKeys < ActiveRecord::Migration[6.0]
  def up
    add_column :api_keys, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :api_keys, :id, :integer_id
    rename_column :api_keys, :uuid, :id

    execute 'ALTER TABLE api_keys drop constraint api_keys_pkey;'
    execute 'ALTER TABLE api_keys ADD PRIMARY KEY (id);'

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY api_keys ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :api_keys, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS api_keys_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
