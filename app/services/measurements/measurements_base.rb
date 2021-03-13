# frozen_string_literal: true

module Measurements
  class MeasurementsBase
    def initialize(user_id:, device_id: nil)
      @device_id = device_id
      @user_id = user_id
    end

    private

    attr_reader :device_id, :user_id

    def query_api
      client.create_query_api
    end

    def write_api
      client.create_write_api
    end

    def client
      @client ||= InfluxDB2::Client.new(
        ENV.fetch('INFLUX_HOST'),
        ENV.fetch('INFLUX_TOKEN'),
        bucket: bucket,
        org: ENV.fetch('INFLUX_ORG'),
        precision: InfluxDB2::WritePrecision::MILLISECOND,
        use_ssl: Rails.env.production? ? true : false
      )
    end

    def bucket
      ENV.fetch('INFLUX_BUCKET')
    end
  end
end
