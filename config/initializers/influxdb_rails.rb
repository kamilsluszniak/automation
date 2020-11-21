# frozen_string_literal: true

InfluxDB::Rails.configure do |config|
  config.client.database = 'automation'
  config.client.hosts = [ENV['INFLUX_HOST']]

  # config.retry = false
  # config.async = false
  # config.open_timeout = 5
  # config.read_timeout = 30
  # config.max_delay = 300
  # config.time_precision = 'ms'

  # config.series_name_for_controller_runtimes = "rails.controller"
  # config.series_name_for_view_runtimes       = "rails.view"
  # config.series_name_for_db_runtimes         = "rails.db"
  # config.series_name_for_exceptions          = "rails.exceptions"
  # config.series_name_for_instrumentation     = "instrumentation"

  # Set the application name to something meaningful, by default we
  # infer the app name from the Rails.application class name.
  # config.application_name = Rails.application.class.parent_name
end
