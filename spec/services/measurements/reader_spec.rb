# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurements::Reader, type: :model do
  context 'when device_id, user_id are given and passed to reader_instance' do
    let(:device_id) { SecureRandom.uuid }
    let(:user_id) { SecureRandom.uuid }
    subject(:reader_instance) { described_class.new(device_name, device_id, user_id) }

    context 'when measurements are not empty' do
      let(:device_name) { 'test_device' }
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

      before do
        (0..3).each do |_i|
          Measurements::Writer.new(
            device_name, device_id, user_id
          ).call(measurements)
        end
      end

      context 'when metric_name is passed' do
        let(:result) { reader_instance.call(metric_name) }

        context 'when `temperature` is metric name' do
          let(:metric_name) { 'temperature' }

          it 'reads measurements' do
            expect(result.length).to eq(4)
            expect(result.map { |x| x[:value] }).to eq([1, 1, 1, 1])
          end

          context 'when device_id doesn`t match' do
            subject(:reader_instance) do
              described_class.new(device_name, 'does-not-match', user_id)
            end

            it 'returns empty data' do
              expect(result.length).to eq(0)
            end
          end
        end

        context 'when `level` is metric name' do
          let(:metric_name) { 'level' }

          it 'reads measurements' do
            expect(result.length).to eq(4)
            expect(result.map { |x| x[:value] }).to eq([100, 100, 100, 100])
          end

          context 'when user_id doesn`t match' do
            subject(:reader_instance) do
              described_class.new(device_name, device_id, 'does-not-match')
            end

            it 'returns empty data' do
              expect(result.length).to eq(0)
            end
          end
        end
      end

      context 'when metric_name doesn`t match' do
        let(:result) { reader_instance.call('does-not-match') }

        it 'returns empty data' do
          expect(result.length).to eq(0)
        end
      end
    end
  end
end
