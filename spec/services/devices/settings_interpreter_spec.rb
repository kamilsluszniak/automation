# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devices::SettingsInterpreter, type: :model do
  describe '#call' do
    subject { described_class.new(settings: settings) }

    context 'when settings are not sorted' do
      let(:settings) do
        {
          lights: {
            time_dependent: true,
            values: {
              540 => {
                on: true,
                dim_factor: 1,
                p_factor: 5.0,
                i_factor: 0.05,
                d_factor: 3.0,
                temp0set: 40
              },
              1260 => {
                on: true,
                dim_factor: 1,
                p_factor: 5.0,
                i_factor: 0.05,
                d_factor: 3.0,
                temp0set: 35,
                uv_on: true
              },
              1320 => {
                on: true,
                dim_factor: 1,
                p_factor: 5.0,
                i_factor: 0.05,
                d_factor: 3.0,
                temp0set: 20
              },
              1380 => {
                on: false,
                dim_factor: 1,
                p_factor: 5.0,
                i_factor: 0.05,
                d_factor: 3.0,
                temp0set: 20
              },
              600 => {
                on: true,
                dim_factor: 1,
                p_factor: 5.0,
                i_factor: 0.05,
                d_factor: 3.0,
                temp0set: 40,
                uv_on: true
              }
            }
          }
        }
      end
      let(:result) do
        Timecop.freeze(Time.new(2008, 9, 1, 10, 0o1, 0, '+00:00')) do
          subject.call
        end
      end

      it 'return correct time setting even if not sorted' do
        expect(result).to eq(
          {
            lights: {
              on: true,
              dim_factor: 1,
              p_factor: 5.0,
              i_factor: 0.05,
              d_factor: 3.0,
              temp0set: 40,
              uv_on: true
            }
          }
        )
      end
    end

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
          Timecop.freeze(Time.new(2008, 9, 1, 9, 59, 0, '+00:00')) do
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
          Timecop.freeze(Time.new(2008, 9, 1, 10, 1, 0, '+00:00')) do
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
          Timecop.freeze(Time.new(2008, 9, 1, 11, 50, 0, '+00:00')) do
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
          Timecop.freeze(Time.new(2008, 9, 1, 9, 59, 0, '+00:00')) do
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
          Timecop.freeze(Time.new(2008, 9, 1, 10, 1, 0, '+00:00')) do
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
          Timecop.freeze(Time.new(2008, 9, 1, 11, 50, 0, '+00:00')) do
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

  context 'when time zone is passed' do
    let(:interpreter_instance) { described_class.new(settings: settings, time_zone: time_zone) }

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

    subject do
      Timecop.freeze(tested_time) do
        interpreter_instance.call
      end
    end

    let(:tested_time) { Time.new(2008, 9, 1, 9, 0o0, 0, '+00:00') }

    context 'when UTC' do
      let(:time_zone) { 'UTC' }

      it {
        is_expected.to eq(
          { light_intensity: { red: 0, green: 0 }, water_height: 300 }
        )
      }
    end

    context 'when Warsaw' do
      let(:time_zone) { 'Warsaw' }

      it {
        is_expected.to eq(
          { light_intensity: { red: 10, green: 40 }, water_height: 300 }
        )
      }
    end

    context 'when Kuwait' do
      let(:time_zone) { 'Kuwait' }

      it {
        is_expected.to eq(
          { light_intensity: { red: 20, green: 50 }, water_height: 300 }
        )
      }
    end

    context 'when Karachi' do
      let(:time_zone) { 'Karachi' }

      it {
        is_expected.to eq(
          { light_intensity: { red: 0, green: 0 }, water_height: 300 }
        )
      }
    end
  end
end
