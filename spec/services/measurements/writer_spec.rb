# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurements::Writer, type: :model do
  context 'when metric name is given' do
    let(:device_id) { SecureRandom.uuid }
    let(:user_id) { SecureRandom.uuid }
    subject(:writer_instance) { described_class.new(device_id: device_id, user_id: user_id) }
    let(:influxdb_point_class) { InfluxDB2::Point }
    let(:influxdb_point_instance) { instance_double(InfluxDB2::Point) }
    let(:write_api_instance) { instance_double(InfluxDB2::WriteApi) }

    context 'when measurements are integer' do
      let(:measurements) do
        [
          {
            name: 'temperature',
            value: 1
          },
          {
            name: 'level',
            value: 100
          }
        ]
      end

      it 'writes integer measurements' do
        expect(influxdb_point_class).to receive(:new).twice.with(name: user_id)
                                                     .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with('temperature', 1)
                                                              .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with('level', 100)
                                                              .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_tag).twice.with('device_id', device_id)
                                                            .and_return(influxdb_point_instance)
        expect(writer_instance).to receive(:write_api).and_return(write_api_instance)
        expect(write_api_instance).to receive(:write).with(data: [influxdb_point_instance, influxdb_point_instance])
        writer_instance.call(measurements)
      end
    end

    context 'when measurements are string-coded integer' do
      let(:measurements) do
        [
          {
            name: 'temperature_string',
            value: '1'
          },
          {
            name: 'level_string',
            value: '100'
          }
        ]
      end

      it 'writes measurements' do
        expect(influxdb_point_class).to receive(:new).twice.with(name: user_id)
                                                     .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with('temperature_string', 1)
                                                              .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with('level_string', 100)
                                                              .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_tag).twice.with('device_id', device_id)
                                                            .and_return(influxdb_point_instance)
        expect(writer_instance).to receive(:write_api).and_return(write_api_instance)
        expect(write_api_instance).to receive(:write).with(data: [influxdb_point_instance, influxdb_point_instance])
        writer_instance.call(measurements)
      end
    end

    context 'when measurements are string-coded float' do
      let(:measurements) do
        [
          {
            name: 'temperature_float',
            value: '1.0'
          },
          {
            name: 'level_float',
            value: '100.00'
          }
        ]
      end

      it 'writes measurements' do
        expect(influxdb_point_class).to receive(:new).twice.with(name: user_id)
                                                     .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with('temperature_float', 1.0)
                                                              .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_field).with('level_float', 100)
                                                              .and_return(influxdb_point_instance)
        expect(influxdb_point_instance).to receive(:add_tag).twice.with('device_id', device_id)
                                                            .and_return(influxdb_point_instance)
        expect(writer_instance).to receive(:write_api).and_return(write_api_instance)
        expect(write_api_instance).to receive(:write).with(data: [influxdb_point_instance, influxdb_point_instance])
        writer_instance.call(measurements)
      end
    end
  end
end
