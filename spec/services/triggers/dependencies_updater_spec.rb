# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::DependenciesUpdater, type: :model do
  context 'when triggers and alerts exist' do
    subject(:dependencies_updater) do
      Triggers::DependenciesUpdater.new(
        user: user, trigger: trigger, is_triggered: is_triggered
      )
    end
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

    context 'when dependency and dependent device exists and is triggered' do
      let(:is_triggered) { true }
      let(:dependencies) do
        {
          devices: {
            dependent_device: {
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

      let(:device) { create(:device, name: 'dependent_device', user: user) }

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

    context 'when dependency and dependent device exists for other user and is triggered' do
      let(:is_triggered) { true }
      let(:dependencies) do
        {
          devices: {
            dependent_device: {
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

      let(:other_user) { create(:user) }
      let(:device) { create(:device, name: 'dependent_device', user: other_user) }

      it 'doesn`t change other user`s device settings' do
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
      end
    end

    context 'when dependency and dependent device exists, is not triggered and has override' do
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

      let(:device) { create(:device, name: 'dependent_device', user: user) }

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

    context 'when dependency and dependent device exists, is triggered with original' do
      let(:is_triggered) { true }

      context 'when device has complex and grouped settings' do
        let(:device) { create(:device, name: 'dependent_device', user: user) }

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

      context 'when device has complex and not grouped settings' do
        let(:settings) do
          {
            pump1_on: false,
            co2_on: { time_dependent: true, values: { 540 => true, 1260 => false } },
            pump2_on: {
              time_dependent: true,
              values: {
                1 => true,
                3 => false,
                11 => true,
                13 => false
              },
              override: nil
            }
          }
        end
        let(:is_triggered) { true }
        let(:device) do
          create(:device, :complex_not_grouped_settings, user: user, name: 'other_device')
        end

        let(:dependencies) do
          {
            devices: {
              other_device: {
                triggered: {
                  pump2_on: false
                },
                not_triggered: {
                  original_settings: nil
                }
              }
            }
          }
        end

        it 'sets trigger device`s original settings once when called twice' do
          expect(device.settings).to eq(settings)

          expect(trigger).to receive(:update).once.with(
            dependencies: {
              devices: {
                other_device: {
                  not_triggered: {
                    original_settings: settings
                  },
                  triggered: {
                    pump2_on: false
                  }
                }
              }
            }
          ).and_call_original

          dependencies_updater.call
          dependencies_updater.call

          expect(device.reload.settings.deep_symbolize_keys).to eq(
            {
              pump2_on: false
            }
          )

          trigger_with_original_settings = Trigger.find(trigger.id)
          expect(trigger_with_original_settings.dependencies).to eq(
            {
              devices: {
                other_device: {
                  triggered: {
                    pump2_on: false
                  },
                  not_triggered: {
                    original_settings: settings
                  }
                }
              }
            }
          )
        end
      end
    end

    context 'when dependency and dependent device exists and returning from triggered' do
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

      let(:device) do
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
