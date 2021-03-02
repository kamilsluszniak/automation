# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::Checker, type: :model do
  context 'when triggers and alerts exist' do
    subject(:triggers_checker) { Triggers::Checker.new(metrics, device_name, user) }

    let(:user) { create(:user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:alerts2) { create_list(:alert, 2, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: alerts) }
    let(:trigger2) { create(:trigger, user: user, alerts: alerts2, metric: 'second_metric') }
    let(:trigger_instance) { instance_double(Trigger) }
    let(:trigger_class) { class_double('Trigger') }
    let(:dependencies_updater_class) { Triggers::DependenciesUpdater }
    let(:dependencies_updater_instance) { instance_double(Triggers::DependenciesUpdater) }

    context 'when 2 metrics in array' do
      let(:metrics) do
        [
          {
            'my_metric' => metric_value
          },
          {
            'second_metric' => second_metric_value
          }
        ]
      end

      context 'when device_name is correct' do
        let(:device_name) { trigger.device }

        context 'when 2 triggers are triggered' do
          let(:metric_value) { 9 }
          let(:second_metric_value) { 9 }

          before do
            allow(trigger_class).to receive(:includes).with(:alerts)
                                                      .and_return([trigger, trigger2])
            allow(trigger_instance).to receive(:alerts).and_return(alerts)
          end

          it 'runs checks, activates alerts and sends 4 emails' do
            expect(user).to receive(:triggers).and_return(trigger_class)
            expect(trigger_class).to receive(:where).with(metric: [trigger.metric, trigger2.metric],
                                                          device: trigger.device, enabled: true)
                                                    .and_return(trigger_class)
            expect(dependencies_updater_class).to receive(:new).with(trigger, true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(trigger2, true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice
                                                                   .and_return(nil)
            expect(trigger.alerts.map(&:active)).to all(be_falsey)

            expect do
              triggers_checker.call
            end.to change {
              ActionMailer::Base.deliveries.count
            }.by(4)

            expect(trigger.alerts.map(&:active)).to all(be_truthy)
            expect(trigger2.alerts.map(&:active)).to all(be_truthy)
          end
        end

        context 'when 1 trigger is triggered' do
          let(:metric_value) { 11 }
          let(:second_metric_value) { 9 }

          before do
            allow(trigger_class).to receive(:includes).with(:alerts)
                                                      .and_return([trigger, trigger2])
            allow(trigger_instance).to receive(:alerts).and_return(alerts)
          end

          it 'runs checks, not activates alerts and not sends 2 emails' do
            expect(trigger_class).to receive(:where).with(metric: [trigger.metric, trigger2.metric],
                                                          device: trigger.device, enabled: true)
                                                    .and_return(trigger_class)
            expect(user).to receive(:triggers).and_return(trigger_class)
            expect(dependencies_updater_class).to receive(:new).with(trigger, false).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_class).to receive(:new).with(trigger2, true).once
                                                               .and_return(dependencies_updater_instance)
            expect(dependencies_updater_instance).to receive(:call).twice
                                                                   .and_return(nil)
            expect(trigger.alerts.map(&:active)).to all(be_falsey)

            expect do
              triggers_checker.call
            end.to change {
              ActionMailer::Base.deliveries.count
            }.by(2)

            expect(trigger.alerts.map(&:active)).to all(be_falsey)
            expect(trigger2.alerts.map(&:active)).to all(be_truthy)
          end
        end
      end
    end
  end
end
