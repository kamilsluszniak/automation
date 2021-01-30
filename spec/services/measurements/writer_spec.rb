# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Measurements::Writer, type: :model do
  context 'when metric name is given' do
    subject(:writer_instance) { described_class.new('test_device') }

    context 'when measurements are not empty' do
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

      it 'writes measurements' do
        expect(subject.call(measurements).code).to eq(204)
      end
    end
  end
end
