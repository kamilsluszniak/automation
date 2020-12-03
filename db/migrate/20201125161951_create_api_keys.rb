# frozen_string_literal: true

class CreateApiKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :key
      t.integer :permission_type
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
