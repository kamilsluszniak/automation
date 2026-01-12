class ConvertTriggersDependenciesToJsonb < ActiveRecord::Migration[6.0]
  def up
    # Add temporary jsonb column
    add_column :triggers, :dependencies_jsonb, :jsonb

    # Convert YAML (from serialize) to JSONB
    trigger_records = fetch_trigger_records
    trigger_records.each do |trigger|
      trigger_id = trigger['id']
      yaml_str = trigger['dependencies']
      next if yaml_str.blank?

      # Parse YAML string and convert to JSON
      parsed = YAML.load(yaml_str)
      json_str = parsed.to_json
      
      # Update the temporary column
      ActiveRecord::Base.connection.execute(
        "UPDATE triggers SET dependencies_jsonb = '#{json_str.gsub("'", "''")}'::jsonb WHERE id = '#{trigger_id}'"
      )
    end

    # Swap columns
    remove_column :triggers, :dependencies
    rename_column :triggers, :dependencies_jsonb, :dependencies
  end

  def down
    # Add temporary string column
    add_column :triggers, :dependencies_yaml, :string

    # Convert JSONB back to YAML string
    trigger_records = ActiveRecord::Base.connection.execute('SELECT id, dependencies FROM triggers')
    trigger_records.each do |trigger|
      trigger_id = trigger['id']
      json_data = trigger['dependencies']
      next if json_data.blank?

      # Parse JSON and convert to YAML string
      parsed = JSON.parse(json_data)
      yaml_str = parsed.to_yaml

      # Update the temporary column
      ActiveRecord::Base.connection.execute(
        "UPDATE triggers SET dependencies_yaml = #{ActiveRecord::Base.connection.quote(yaml_str)} WHERE id = '#{trigger_id}'"
      )
    end

    # Swap columns
    remove_column :triggers, :dependencies
    rename_column :triggers, :dependencies_yaml, :dependencies
  end

  private

  def fetch_trigger_records
    ActiveRecord::Base.connection.execute('SELECT id, dependencies FROM triggers')
  end
end
