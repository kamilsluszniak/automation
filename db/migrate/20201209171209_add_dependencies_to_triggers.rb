# frozen_string_literal: true

class AddDependenciesToTriggers < ActiveRecord::Migration[6.0]
  def change
    add_column :triggers, :dependencies, :string
  end
end
