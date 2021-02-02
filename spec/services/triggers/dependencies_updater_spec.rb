# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::DependenciesUpdater, type: :model do
  context 'when triggers and alerts exist' do
    subject(:dependencies_updater) { Triggers::DependenciesUpdater.new(trigger, is_triggered) }
    let(:user) { create(:user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: alerts) }

    before do
      allow(trigger).to receive(:dependencies).and_return(dependencies)
      allow(trigger).to receive(:alerts).and_return([])
    end

    let(:device_settings) do
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

    context 'when dependency and dependent device exist and triggered' do
      let(:is_triggered) { true }
      let(:dependencies) do
        {
          devices: {
            'dependent_device': {
              triggered: {
                on: true
              },
              not_triggered: {
                on: false
              }
            }
          }
        }
      end

      let!(:device) { create(:device, name: 'dependent_device', user: user) }

      it 'sets dependent device`s settings' do
        expect(device.settings).to eq(
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
        )

        dependencies_updater.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(
          {
            on: true
          }
        )
      end
    end

    context 'when dependency and dependent device exist, not triggered with override' do
      let(:is_triggered) { false }
      let(:dependencies) do
        {
          devices: {
            'dependent_device': {
              triggered: {
                on: true
              },
              not_triggered: {
                on: false
              }
            }
          }
        }
      end

      let!(:device) { create(:device, name: 'dependent_device', user: user) }

      it 'sets dependent device`s settings when not triggered to override' do
        expect(device.settings).to eq(device_settings)

        dependencies_updater.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(
          {
            on: false
          }
        )
      end
    end

    context 'when dependency and dependent device exist, triggered with original' do
      let(:is_triggered) { true }
      let(:dependencies) do
        {
          devices: {
            'dependent_device': {
              triggered: {
                on: true
              },
              not_triggered: {
                original_settings: nil
              }
            }
          }
        }
      end

      let!(:device) { create(:device, name: 'dependent_device', user: user) }

      it 'sets trigger device`s original settings' do
        expect(device.settings).to eq(device_settings)
        updated_dependencies = dependencies.merge(
          {
            devices: {
              device.name => {
                triggered: {
                  on: true
                },
                not_triggered: {
                  original_settings: device_settings
                }
              }
            }
          }
        )

        expect(trigger).to receive(:update).with(dependencies: updated_dependencies.deep_symbolize_keys)
        dependencies_updater.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(
          {
            on: true
          }
        )
      end
    end

    context 'when dependency and dependent device exist and returning from triggered' do
      let(:is_triggered) { false }
      let(:dependencies) do
        {
          devices: {
            dependent_device1: {
              triggered: {
                on: true
              },
              not_triggered: {
                original_settings: device_settings
              }
            }
          }
        }
      end

      let!(:device) do
        create(
          :device,
          name: 'dependent_device1',
          user: user,
          settings: {
            on: true
          }
        )
      end
      let(:trigger_instance) { instance_double(Trigger) }

      it 'sets dependent device`s settings' do
        expect(device.settings).to eq(
          {
            on: true
          }
        )

        dependencies_updater.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(device_settings)
      end
    end
  end
end
