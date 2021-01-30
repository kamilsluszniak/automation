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
        point.add_field(*metric.first)
      end
      point
    end
  end
end
