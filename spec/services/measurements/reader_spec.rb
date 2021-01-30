# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurements::Reader, type: :model do
  context 'when metric name is given' do
    subject(:reader_instance) { described_class.new(device_name) }

    context 'when measurements are not empty' do
      let(:device_name) { "test_device_#{SecureRandom.uuid}" }
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
          Measurements::Writer.new(device_name).call(measurements)
        end
      end

      context 'when temperature results get returned' do
        let(:result) { reader_instance.call('temperature') }

        it 'reads measurements' do
          reader_instance.call('temperature')
          expect(result.length).to eq(4)
          expect(result.map { |x| x[:value] }).to eq([1, 1, 1, 1])
        end
      end

      context 'when level results get returned' do
        let(:result) { reader_instance.call('level') }

        it 'reads measurements' do
          reader_instance.call('temperature')
          expect(result.length).to eq(4)
          expect(result.map { |x| x[:value] }).to eq([100, 100, 100, 100])
        end
      end
    end
  end
end
