# frozen_string_literal: true

module Measurements
  class Writer < Measurements::MeasurementsBase
    def call(measurements_array)
      points = data_points(measurements_array)
      write_api.write(data: points)
    end

    private

    def data_points(arr)
      arr.map do |metric|
        point = InfluxDB2::Point.new(name: user_id)

        parsed = StringValuesParser.call(metric[:value])

        point.add_field(metric[:name], parsed)
             .add_tag('device_id', device_id)
      end
    end
  end
end
