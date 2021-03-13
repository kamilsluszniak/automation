# frozen_string_literal: true

class AddAncestryToTriggers < ActiveRecord::Migration[6.0]
  def change
    add_column :triggers, :ancestry, :string
    add_index :triggers, :ancestry
  end
end
