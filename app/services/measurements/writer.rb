# frozen_string_literal: true

module Measurements
  class Writer < Measurements::MeasurementsBase
    FLOAT_PATTERN = /\d+\.\d+/.freeze

    def call(measurements_array)
      data_point = map_metrics_array_to_data_point(measurements_array)
      write_api.write(data: data_point)
    end

    private

    def map_metrics_array_to_data_point(arr)
      point = InfluxDB2::Point.new(name: @device_name)

      arr.each do |metric|
        parsed = metric.transform_values { |val| detect_type_and_convert(val) }
        point.add_field(*parsed.first)
      end
      point
    end

    def detect_type_and_convert(value)
      return value unless value.is_a? String

      if value.match(FLOAT_PATTERN)
        value.to_f
      else
        value.to_i
      end
    end
  end
end
