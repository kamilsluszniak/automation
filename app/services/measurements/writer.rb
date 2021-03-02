# frozen_string_literal: true

module Measurements
  class Writer < Measurements::MeasurementsBase
    def call(measurements_array)
      data_point = map_metrics_array_to_data_point(measurements_array)
      write_api.write(data: data_point)
    end

    private

    def map_metrics_array_to_data_point(arr)
      point = InfluxDB2::Point.new(name: @device_name)

      arr.each do |metric|
        parsed = metric.transform_values { |val| StringValuesParser.call(val) }
        point.add_field(*parsed.first)
             .add_tag('device_id', device_id)
             .add_tag('user_id', user_id)
      end
      point
    end
  end
end
