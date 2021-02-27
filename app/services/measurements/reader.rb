# frozen_string_literal: true

module Measurements
  class Reader < Measurements::MeasurementsBase
    def call(metric_name, minutes_ago: 60)
      query = build_query(metric_name, minutes_ago)
      result = query_api.query(query: query)
      return [] if result.empty?

      result.values.first.records.map do |record|
        {
          value: record.values['_value'],
          time: record.values['_time']
        }
      end
    end

    private

    attr_reader :minutes_ago

    def build_query(metric_name, minutes_ago)
      "from(bucket:\"#{bucket}\") "\
      "|> range(start: -#{minutes_ago}m) "\
      '|> filter (fn: (r) => '\
      "r._measurement == \"#{device_name}\" and "\
      "r._field == \"#{metric_name}\" and "\
      "r.device_id == \"#{device_id}\" and "\
      "r.user_id == \"#{user_id}\")"
    end
  end
end
