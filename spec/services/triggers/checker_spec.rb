# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::Checker, type: :model do
  context 'when triggers and alerts exist' do
    subject(:triggers_checker) { Triggers::Checker.new(user) }

    let(:user) { create(:user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:sibling_trigger_alerts) { create_list(:alert, 2, user: user) }
    let(:alerts2) { create_list(:alert, 2, user: user) }
    let(:alerts3) { create_list(:alert, 2, user: user) }
    let(:sibling_device) { create(:device, user: user, name: 'sibling_sensor') }
    let(:device1) { create(:device, user: user, name: 'sensor1') }
    let(:device2) { create(:device, user: user, name: 'sensor2') }
    let(:device3) { create(:device, user: user, name: 'sensor3') }

    let(:sibling_trigger) do
      create(
        :trigger,
        user: user,
        alerts: sibling_trigger_alerts,
        metric: 'sibling_metric',
        device: sibling_device,
        value: 10,
        enabled: true,
        operator: '>'
      )
    end

    let!(:trigger) do
      create(
        :trigger,
        user: user,
        alerts: alerts,
        metric: 'sensor1_metric',
        value: 10,
        enabled: true,
        operator: parent_trigger_operator
      )
    end

    let!(:trigger2) do
      create(
        :trigger,
        user: user,
        alerts: alerts2,
        metric: 'sensor2_metric',
        device: device2,
        operator: '>',
        value: 5,
        parent: trigger,
        enabled: true
      )
    end
    let!(:trigger3) do
      create(
        :trigger,
        user: user,
        alerts: alerts3,
        metric: 'sensor3_metric',
        device: device3,
        operator: '>',
        value: 5,
        parent: trigger,
        enabled: true
      )
    end
    let(:measurements_reader_class) { Measurements::Reader }
    let(:measurements_reader_instance) { instance_double(Measurements::Reader) }
    let(:dependencies_updater_class) { Triggers::DependenciesUpdater }
    let(:dependencies_updater_instance) { instance_double(Triggers::DependenciesUpdater) }
    let(:alerts_runner_class) { Alerts::Runner }
    let(:alerts_runner_instance) { instance_double(Alerts::Runner) }

    context 'when 3 data points from 3 devices are in measurements response' do
      let(:measurements_reader_response) do
        [
          [
            {
              'result' => nil,
              'table' => 0,
              '_start' => Time.zone.now.to_s,
              '_stop' => Time.zone.now.to_s,
              '_time' => Time.zone.now.to_s,
              '_value' => trigger2_metric_value,
              '_field' => trigger2.metric,
              '_measurement' => user.id,
              'device_id' => device2.id
            }
          ],
          [
            {
              'result' => nil,
              'table' => 1,
              '_start' => Time.zone.now.to_s,
              '_stop' => Time.zone.now.to_s,
              '_time' => Time.zone.now.to_s,
              '_value' => trigger3_metric_value,
              '_field' => trigger3.metric,
              '_measurement' => user.id,
              'device_id' => device3.id
            }
          ],
          [
            {
              'result' => nil,
              'table' => 2,
              '_start' => Time.zone.now.to_s,
              '_stop' => Time.zone.now.to_s,
              '_time' => Time.zone.now.to_s,
              '_value' => sibling_trigger_metric_value,
              '_field' => sibling_trigger.metric,
              '_measurement' => user.id,
              'device_id' => sibling_device.id
            }
          ]
        ]
      end

      let(:query_data) do
        [
          { device_id: nil, metric_name: trigger.metric },
          { device_id: device2.id, metric_name: trigger2.metric },
          { device_id: device3.id, metric_name: trigger3.metric },
          { device_id: sibling_device.id, metric_name: sibling_trigger.metric }
        ]
      end

      context 'when parent trigger has AND operator' do
        let(:parent_trigger_operator) { 'AND' }

        context 'when 1 child trigger is triggered and 1 not' do
          let(:trigger2_metric_value) { 6 }
          let(:trigger3_metric_value) { 4 }
          let(:sibling_trigger_metric_value) { 0 }

          it 'not triggers parent' do
            expect(measurements_reader_class).to receive(:new).once.with(user_id: user.id)
                                                              .and_return(measurements_reader_instance)
            expect(measurements_reader_instance).to receive(:call).once.with(query_data, last_only: true)
                                                                  .and_return(measurements_reader_response)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: sibling_trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice.and_return(nil)
            expect(alerts_runner_class).to receive(:new).with(trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_class).to receive(:new).with(sibling_trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_instance).to receive(:call).twice

            triggers_checker.call
          end
        end

        context 'both child triggers are triggered' do
          let(:trigger2_metric_value) { 6 }
          let(:trigger3_metric_value) { 6 }
          let(:sibling_trigger_metric_value) { 0 }

          it 'triggers parent' do
            expect(measurements_reader_class).to receive(:new).once.with(user_id: user.id)
                                                              .and_return(measurements_reader_instance)
            expect(measurements_reader_instance).to receive(:call).once.with(query_data, last_only: true)
                                                                  .and_return(measurements_reader_response)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: trigger,
                                                                     is_triggered: true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: sibling_trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice.and_return(nil)

            expect(alerts_runner_class).to receive(:new).with(trigger, true).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_class).to receive(:new).with(sibling_trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_instance).to receive(:call).twice

            triggers_checker.call
          end
        end

        context 'both child triggers are triggered along with sibling trigger' do
          let(:trigger2_metric_value) { 6 }
          let(:trigger3_metric_value) { 6 }
          let(:sibling_trigger_metric_value) { 11 }

          it 'triggers parent' do
            expect(measurements_reader_class).to receive(:new).once.with(user_id: user.id)
                                                              .and_return(measurements_reader_instance)
            expect(measurements_reader_instance).to receive(:call).once.with(query_data, last_only: true)
                                                                  .and_return(measurements_reader_response)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: trigger,
                                                                     is_triggered: true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: sibling_trigger,
                                                                     is_triggered: true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice.and_return(nil)
            expect(alerts_runner_class).to receive(:new).with(trigger, true).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_class).to receive(:new).with(sibling_trigger, true).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_instance).to receive(:call).twice

            triggers_checker.call
          end
        end
      end

      context 'when parent trigger has OR operator' do
        let(:parent_trigger_operator) { 'OR' }

        context 'when 1 child trigger is triggered and 1 not, sibling not triggered' do
          let(:trigger2_metric_value) { 6 }
          let(:trigger3_metric_value) { 4 }
          let(:sibling_trigger_metric_value) { 0 }

          it 'not triggers parent' do
            expect(measurements_reader_class).to receive(:new).once.with(user_id: user.id)
                                                              .and_return(measurements_reader_instance)
            expect(measurements_reader_instance).to receive(:call).once.with(query_data, last_only: true)
                                                                  .and_return(measurements_reader_response)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: trigger,
                                                                     is_triggered: true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: sibling_trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice.and_return(nil)
            expect(alerts_runner_class).to receive(:new).with(trigger, true).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_class).to receive(:new).with(sibling_trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_instance).to receive(:call).twice

            triggers_checker.call
          end
        end

        context 'both child triggers are triggered, sibling not triggered' do
          let(:trigger2_metric_value) { 6 }
          let(:trigger3_metric_value) { 6 }
          let(:sibling_trigger_metric_value) { 0 }

          it 'runs checks for child triggers and not triggers parent when not all triggered with AND' do
            expect(measurements_reader_class).to receive(:new).once.with(user_id: user.id)
                                                              .and_return(measurements_reader_instance)
            expect(measurements_reader_instance).to receive(:call).once.with(query_data, last_only: true)
                                                                  .and_return(measurements_reader_response)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: trigger,
                                                                     is_triggered: true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: sibling_trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice.and_return(nil)
            expect(alerts_runner_class).to receive(:new).with(trigger, true).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_class).to receive(:new).with(sibling_trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_instance).to receive(:call).twice

            triggers_checker.call
          end
        end

        context 'when measurements are empty' do
          let(:measurements_reader_response) { [] }

          it 'runs checks for child triggers and not triggers anything' do
            expect(measurements_reader_class).to receive(:new).once.with(user_id: user.id)
                                                              .and_return(measurements_reader_instance)
            expect(measurements_reader_instance).to receive(:call).once.with(query_data, last_only: true)
                                                                  .and_return(measurements_reader_response)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(user: user, trigger: sibling_trigger,
                                                                     is_triggered: false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice.and_return(nil)
            expect(alerts_runner_class).to receive(:new).with(trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_class).to receive(:new).with(sibling_trigger, false).once
                                                        .and_return(alerts_runner_instance)
            expect(alerts_runner_instance).to receive(:call).twice

            triggers_checker.call
          end
        end
      end
    end
  end

  context 'when no triggers and no alerts exist' do
    subject(:triggers_checker) { Triggers::Checker.new(user) }

    let(:user) { create(:user) }

    it 'returns nil' do
      expect(triggers_checker.call).to eq(nil)
    end
  end
end
