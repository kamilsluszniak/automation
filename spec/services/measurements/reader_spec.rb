# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurements::Reader, type: :model do
  context 'when device_id, user_id are given and passed to reader_instance' do
    let(:device1_id) { SecureRandom.uuid }
    let(:device2_id) { SecureRandom.uuid }
    let(:user_id) { SecureRandom.uuid }
    let(:other_user_id) { SecureRandom.uuid }

    subject(:reader_instance) { described_class.new(user_id: user_id) }

    context 'when measurements1 and measurements2 are not empty' do
      let(:measurements1) do
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

      let(:measurements2) do
        [
          {
            name: 'humidity',
            value: 80
          },
          {
            name: 'saturation',
            value: 20
          }
        ]
      end

      before do
        (0..1).each do |_i|
          Measurements::Writer.new(device_id: device1_id, user_id: user_id).call(measurements1)
          Measurements::Writer.new(device_id: device2_id, user_id: user_id).call(measurements2)
          Measurements::Writer.new(device_id: device2_id, user_id: other_user_id).call(measurements2)
        end
      end

      context 'when data is empty' do
        let(:result) { reader_instance.call(data) }
        let(:data) { [] }

        it 'raises EmptyMetricPairDataException' do
          expect { result }.to raise_error Measurements::EmptyMetricPairDataException
        end
      end

      context 'when data is nil' do
        let(:result) { reader_instance.call(data) }
        let(:data) { nil }

        it 'raises EmptyMetricPairDataException' do
          expect { result }.to raise_error Measurements::EmptyMetricPairDataException
        end
      end

      context 'when data is passed' do
        let(:result) { reader_instance.call(data) }

        context 'when querying for device1 temperature and level' do
          let(:data) do
            [
              { device_id: device1_id, metric_name: 'temperature' },
              { device_id: device1_id, metric_name: 'level' }
            ]
          end

          it 'returns array of 2 measurements 2 points long from 1 device' do
            expect(result.length).to eq(2)

            level_results = result.find { |i| i.find { |x| x['_field'] == 'level' } }
            temperature_results = result.find { |i| i.find { |x| x['_field'] == 'temperature' } }

            expect(level_results.length).to eq(2)
            expect(temperature_results.length).to eq(2)

            expect(level_results.map { |x| x['_value'] }).to eq([100, 100])
            expect(level_results.map { |x| x['_measurement'] }).to eq([user_id, user_id])
            expect(level_results.map { |x| x['device_id'] }).to eq([device1_id, device1_id])

            expect(temperature_results.map { |x| x['_value'] }).to eq([1, 1])
            expect(temperature_results.map { |x| x['_measurement'] }).to eq([user_id, user_id])
            expect(temperature_results.map { |x| x['device_id'] }).to eq([device1_id, device1_id])
          end

          context 'when user_id doesn`t match' do
            subject(:reader_instance) do
              described_class.new(user_id: 'does-not-match')
            end

            it 'returns empty data' do
              expect(result.length).to eq(0)
            end
          end
        end

        context 'when querying for device1 temperature and device2 humidity' do
          let(:data) do
            [
              { device_id: device1_id, metric_name: 'temperature' },
              { device_id: device2_id, metric_name: 'humidity' }
            ]
          end

          it 'returns array of 2 measurements 2 points long from 2 devices' do
            expect(result.length).to eq(2)

            humidity_results = result.find { |i| i.find { |x| x['_field'] == 'humidity' } }
            temperature_results = result.find { |i| i.find { |x| x['_field'] == 'temperature' } }

            expect(humidity_results.length).to eq(2)
            expect(temperature_results.length).to eq(2)

            expect(humidity_results.map { |x| x['_value'] }).to eq([80, 80])
            expect(humidity_results.map { |x| x['_measurement'] }).to eq([user_id, user_id])
            expect(humidity_results.map { |x| x['device_id'] }).to eq([device2_id, device2_id])

            expect(temperature_results.map { |x| x['_value'] }).to eq([1, 1])
            expect(temperature_results.map { |x| x['_measurement'] }).to eq([user_id, user_id])
            expect(temperature_results.map { |x| x['device_id'] }).to eq([device1_id, device1_id])
          end

          context 'when `last_only` param is true' do
            let(:result) { reader_instance.call(data, last_only: true) }

            it 'returns array of 2 measurements 1 point long from 1 device' do
              expect(result.length).to eq(2)

              humidity_results = result.find { |i| i.find { |x| x['_field'] == 'humidity' } }
              temperature_results = result.find { |i| i.find { |x| x['_field'] == 'temperature' } }

              expect(humidity_results.length).to eq(1)
              expect(temperature_results.length).to eq(1)

              expect(humidity_results.map { |x| x['_value'] }).to eq([80])
              expect(humidity_results.map { |x| x['_measurement'] }).to eq([user_id])
              expect(humidity_results.map { |x| x['device_id'] }).to eq([device2_id])

              expect(temperature_results.map { |x| x['_value'] }).to eq([1])
              expect(temperature_results.map { |x| x['_measurement'] }).to eq([user_id])
              expect(temperature_results.map { |x| x['device_id'] }).to eq([device1_id])
            end
          end

          context 'when user_id doesn`t match' do
            subject(:reader_instance) do
              described_class.new(user_id: 'does-not-match')
            end

            it 'returns empty data' do
              expect(result.length).to eq(0)
            end
          end
        end

        context 'when querying for metric that doesnt exist' do
          let(:data) do
            [
              { device_id: device1_id, metric_name: 'power' }
            ]
          end

          it 'returns empty data' do
            expect(result.length).to eq(0)
          end
        end
      end
    end
  end
end
