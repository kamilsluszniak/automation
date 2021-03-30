# frozen_string_literal: true

module Measurements
  class Reader < Measurements::MeasurementsBase
    def call(device_metric_pair_data, minutes_ago: 60, last_only: false)
      raise EmptyMetricPairDataException if device_metric_pair_data.blank?

      query = build_query(device_metric_pair_data, minutes_ago, last_only)
      result = query_api.query(query: query)

      return [] if result.empty?

      result.map do |_key, field|
        field.records.map(&:values)
      end
    end

    private

    attr_reader :minutes_ago, :device_name, :device_id

    # rubocop:disable Style/StringConcatenation
    def build_query(device_metric_pair_data, minutes_ago, last_only)
      "from(bucket:\"#{bucket}\") "\
      "|> range(start: -#{minutes_ago}m) "\
      '|> filter (fn: (r) => '\
      "r._measurement == \"#{user_id}\" and "\
      '(' + devices_metrics_conditions(device_metric_pair_data) + ')' + last_conditional(last_only)
    end
    # rubocop:enable Style/StringConcatenation

    def last_conditional(last_only)
      last_only ? '|> last()' : ''
    end

    def devices_metrics_conditions(device_metric_pair_data)
      size = device_metric_pair_data.size
      buffer = +''
      device_metric_pair_data.each_with_index do |data, i|
        buffer << "(r.device_id == \"#{data[:device_id]}\" and "\
                  "r._field == \"#{data[:metric_name]}\")"
        buffer << if i == size - 1
                    ')'
                  else
                    ' or '
                  end
      end
      buffer
    end
  end
end
