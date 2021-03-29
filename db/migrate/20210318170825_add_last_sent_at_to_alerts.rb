# frozen_string_literal: true

class AddLastSentAtToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :last_sent_at, :datetime
  end
end
