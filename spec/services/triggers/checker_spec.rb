# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::Checker, type: :model do
  context 'when triggers and alerts exist' do
    let(:user) { create(:user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: alerts) }
    let(:trigger_instance) { instance_double(Trigger) }
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
    let(:dependencies) { {} }

    context 'when trigger is triggered' do
      before do
        allow(trigger_instance).to receive(:triggered?).and_return(true)
        allow(trigger_instance).to receive(:dependencies).and_return(dependencies)
        allow(trigger_instance).to receive(:alerts).and_return(alerts)
        allow(Trigger).to receive(:all).and_return([trigger_instance])
      end

      it 'runs checks, activates alerts and sends emails' do
        expect(trigger.alerts.map(&:active)).to all(be_falsey)
        expect do
          Triggers::Checker.new.call
        end.to change {
          ActionMailer::Base.deliveries.count
        }.by(2)

        expect(trigger.alerts.map(&:active)).to all(be_truthy)
      end
    end

    context 'when trigger is not triggered' do
      before do
        allow(trigger_instance).to receive(:triggered?).and_return(false)
        allow(trigger_instance).to receive(:dependencies).and_return(dependencies)
        allow(trigger_instance).to receive(:alerts).and_return(alerts)
        allow(Trigger).to receive(:all).and_return([trigger_instance])
      end

      it 'runs checks, not activates alerts and not sends emails' do
        expect(trigger.alerts.map(&:active)).to all(be_falsey)

        Triggers::Checker.new.call
        expect(trigger.alerts.map(&:active)).to all(be_falsey)
      end
    end

    context 'when dependency and dependent device exist and triggered' do
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

      before do
        allow(trigger_instance).to receive(:triggered?).and_return(true)
        allow(trigger_instance).to receive(:dependencies).and_return(dependencies)
        allow(trigger_instance).to receive(:alerts).and_return([])
        allow(Trigger).to receive(:all).and_return([trigger_instance])
      end

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

        Triggers::Checker.new.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(
          {
            on: true
          }
        )
      end
    end

    context 'when dependency and dependent device exist, not triggered with override' do
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
      let(:trigger_instance) { instance_double(Trigger) }

      before do
        allow(trigger_instance).to receive(:triggered?).and_return(false)
        allow(trigger_instance).to receive(:dependencies).and_return(dependencies)
        allow(trigger_instance).to receive(:alerts).and_return([])
        allow(Trigger).to receive(:all).and_return([trigger_instance])
      end

      it 'sets dependent device`s settings when not triggered to override' do
        expect(device.settings).to eq(device_settings)

        Triggers::Checker.new.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(
          {
            on: false
          }
        )
      end
    end

    context 'when dependency and dependent device exist, triggered with original' do
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
      let(:trigger_instance) { instance_double(Trigger) }

      before do
        allow(trigger_instance).to receive(:triggered?).and_return(true)
        allow(trigger_instance).to receive(:dependencies).and_return(dependencies)
        allow(trigger_instance).to receive(:alerts).and_return([])
        allow(Trigger).to receive(:all).and_return([trigger_instance])
      end

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

        expect(trigger_instance).to receive(:update).with(dependencies: updated_dependencies.deep_symbolize_keys)
        Triggers::Checker.new.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(
          {
            on: true
          }
        )
      end
    end

    context 'when dependency and dependent device exist and returning from triggered' do
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

      before do
        allow(trigger_instance).to receive(:triggered?).and_return(false)
        allow(trigger_instance).to receive(:dependencies).and_return(dependencies)
        allow(trigger_instance).to receive(:alerts).and_return([])
        allow(Trigger).to receive(:all).and_return([trigger_instance])
      end

      it 'sets dependent device`s settings' do
        expect(device.settings).to eq(
          {
            on: true
          }
        )

        Triggers::Checker.new.call
        expect(device.reload.settings.deep_symbolize_keys).to eq(device_settings)
      end
    end
  end
end
