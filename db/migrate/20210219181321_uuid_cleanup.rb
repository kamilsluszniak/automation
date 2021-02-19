# frozen_string_literal: true

class UuidCleanup < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def up
    change_column_null :alerts, :user_id, false
    change_column_null :api_keys, :user_id, false
    change_column_null :charts, :user_id, false
    change_column_null :triggers, :user_id, false
    change_column_null :devices, :user_id, false

    remove_column :devices, :user_old_id if ActiveRecord::Base.connection.column_exists?(:devices, :user_old_id)
    remove_column :alerts, :user_old_id if ActiveRecord::Base.connection.column_exists?(:alerts, :user_old_id)
    remove_column :triggers, :user_old_id if ActiveRecord::Base.connection.column_exists?(:triggers, :user_old_id)
    remove_column :api_keys, :user_old_id if ActiveRecord::Base.connection.column_exists?(:api_keys, :user_old_id)

    remove_column :users, :integer_id if ActiveRecord::Base.connection.column_exists?(:users, :integer_id)
    remove_column :triggers, :integer_id if ActiveRecord::Base.connection.column_exists?(:triggers, :integer_id)
    remove_column :api_keys, :integer_id if ActiveRecord::Base.connection.column_exists?(:api_keys, :integer_id)
    remove_column :alerts, :integer_id if ActiveRecord::Base.connection.column_exists?(:alerts, :integer_id)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
