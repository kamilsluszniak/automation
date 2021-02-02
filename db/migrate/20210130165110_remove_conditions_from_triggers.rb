# frozen_string_literal: true

class RemoveConditionsFromTriggers < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      change_table :triggers, bulk: true do |t|
        dir.up do
          t.remove :conditions
          t.string :value
          t.string :operator
          t.string :metric
          t.string :device
        end

        dir.down do
          t.string :conditions
          t.remove :value
          t.remove :operator
          t.remove :metric
          t.remove :device
        end
      end
    end
  end
end
