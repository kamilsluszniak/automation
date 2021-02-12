# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurements::Writer, type: :model do
  context 'when metric name is given' do
    let(:device_name) { 'test_device' }
    subject(:writer_instance) { described_class.new(device_name) }
    let(:influxdb_point_class) { InfluxDB2::Point }
    let(:influxdb_point_instance) { instance_double(InfluxDB2::Point) }
    # let(:influxdb_client_class) { InfluxDB2::Client }
    # let(:influxdb_client_instane) { instance_double(InfluxDB2::Client) }

    before do
      allow(influxdb_point_class).to receive(:new).with(name: device_name)
                                                  .and_return(influxdb_point_instance)
      allow(influxdb_point_instance).to receive(:add_field)
        .and_return(influxdb_point_instance)
      # allow(influxdb_client_class).to receive(:new)
      #   .and_return(influxdb_client_instance)
      # allow(influxdb_client_instance).to receive(:create_write_api)
      #   .and_call_original
    end

    context 'when measurements are integer' do
      let(:measurements) do
        [
          {
            temperature: 1
          },
          {
            level: 100
          }
        ]
      end

      it 'writes integer measurements' do
        # expect(subject.call(measurements).code).to eq('204')
        expect(influxdb_point_class).to receive(:new).with(name: device_name)
                                                     .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with(:temperature, 1)
        writer_instance.call(measurements)
      end
    end

    context 'when measurements are string-coded integer' do
      let(:measurements) do
        [
          {
            temperature_string: '1'
          },
          {
            level_string: '1'
          }
        ]
      end

      it 'writes measurements' do
        expect(influxdb_point_class).to receive(:new).with(name: device_name)
                                                     .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with(:temperature_string, 1)
        writer_instance.call(measurements)
      end
    end

    context 'when measurements are string-coded float' do
      let(:measurements) do
        [
          {
            temperature_float: '1.0'
          },
          {
            level_float: '100.00'
          }
        ]
      end

      it 'writes measurements' do
        expect(influxdb_point_class).to receive(:new).with(name: device_name)
                                                     .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with(:temperature_float, 1.0)
        writer_instance.call(measurements)
      end
    end
  end
end
