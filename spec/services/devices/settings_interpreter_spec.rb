# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devices::SettingsInterpreter, type: :model do
  describe '#call' do
    subject { described_class.new(settings) }

    context 'when override is not present' do
      let(:settings) do
        {
          light_intensity: {
            time_dependent: true,
            values: {
              600 => {
                red: 10,
                green: 40
              },
              700 => {
                red: 20,
                green: 50
              },
              800 => {
                red: 0,
                green: 0
              }
            }
          },
          water_height: 300
        }
      end

      context 'when time is less than first element' do
        let(:result) do
          Timecop.freeze(Time.new(2008, 9, 1, 9, 59, 0, "+00:00")) do
            subject.call
          end
        end

        it 'returns previous day`s last value of light intensity and static setting' do
          expect(result).to eq(
            {
              light_intensity: {
                red: 0,
                green: 0
              },
              water_height: 300
            }
          )
        end
      end

      context 'when time is bigger than first element' do
        let(:result) do
          Timecop.freeze(Time.new(2008, 9, 1, 10, 1, 0, "+00:00")) do
            subject.call
          end
        end

        it 'returns previous day`s last value of light intensity and static setting' do
          expect(result).to eq(
            {
              light_intensity: {
                red: 10,
                green: 40
              },
              water_height: 300
            }
          )
        end
      end

      context 'when time is bigger than second element' do
        let(:result) do
          Timecop.freeze(Time.new(2008, 9, 1, 11, 50, 0, "+00:00")) do
            subject.call
          end
        end

        it 'returns previous day`s last value of light intensity and static setting' do
          expect(result).to eq(
            {
              light_intensity: {
                red: 20,
                green: 50
              },
              water_height: 300
            }
          )
        end
      end
    end

    context 'when override is present' do
      let(:settings) do
        {
          light_intensity: {
            time_dependent: true,
            override: {
              red: 100,
              green: 400
            },
            values: {
              600 => {
                red: 10,
                green: 40
              },
              700 => {
                red: 20,
                green: 50
              },
              800 => {
                red: 0,
                green: 0
              }
            }
          },
          water_height: 300
        }
      end

      context 'when time is less than first element' do
        let(:result) do
          Timecop.freeze(Time.new(2008, 9, 1, 9, 59, 0, "+00:00")) do
            subject.call
          end
        end

        it 'returns overriden light intensity and static setting' do
          expect(result).to eq(
            {
              light_intensity: {
                red: 100,
                green: 400
              },
              water_height: 300
            }
          )
        end
      end

      context 'when time is bigger than first element' do
        let(:result) do
          Timecop.freeze(Time.new(2008, 9, 1, 10, 1, 0, "+00:00")) do
            subject.call
          end
        end

        it 'returns overriden light intensity and static setting' do
          expect(result).to eq(
            {
              light_intensity: {
                red: 100,
                green: 400
              },
              water_height: 300
            }
          )
        end
      end

      context 'when time is bigger than second element' do
        let(:result) do
          Timecop.freeze(Time.new(2008, 9, 1, 11, 50, 0, "+00:00")) do
            subject.call
          end
        end

        it 'returns overriden light intensity and static setting' do
          expect(result).to eq(
            {
              light_intensity: {
                red: 100,
                green: 400
              },
              water_height: 300
            }
          )
        end
      end
    end
  end
end
