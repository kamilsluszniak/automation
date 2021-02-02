# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::Checker, type: :model do
  context 'when triggers and alerts exist' do
    subject(:triggers_checker) { Triggers::Checker.new(metric_name, device_name) }
    let(:metric_name) { 'example_metric' }
    let(:device_name) { 'example_device' }
    let(:user) { create(:user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: alerts) }
    let(:trigger_instance) { instance_double(Trigger) }
    let(:dependencies_updater_class) { Triggers::DependenciesUpdater }
    let(:dependencies_updater_instance) { instance_double(Triggers::DependenciesUpdater) }

    context 'when trigger is triggered' do
      before do
        allow(subject).to receive(:triggers_to_check).with(metric_name)
                                                     .and_return([trigger_instance])
        allow(subject).to receive(:triggered?).with(trigger_instance)
                                              .and_return(true)
        allow(dependencies_updater_class).to receive(:new).with(trigger_instance, true)
                                                          .and_return(dependencies_updater_instance)

        allow(trigger_instance).to receive(:alerts).and_return(alerts)
      end

      it 'runs checks, activates alerts and sends emails' do
        expect(dependencies_updater_instance).to receive(:call)
          .and_return(nil)
        expect(trigger.alerts.map(&:active)).to all(be_falsey)
        expect do
          triggers_checker.call
        end.to change {
          ActionMailer::Base.deliveries.count
        }.by(2)

        expect(trigger.alerts.map(&:active)).to all(be_truthy)
      end
    end

    context 'when trigger is not triggered' do
      before do
        allow(subject).to receive(:triggers_to_check).with(metric_name)
                                                     .and_return([trigger_instance])
        allow(subject).to receive(:triggered?).with(trigger_instance)
                                              .and_return(false)
        allow(dependencies_updater_class).to receive(:new).with(trigger_instance, false)
                                                          .and_return(dependencies_updater_instance)

        allow(trigger_instance).to receive(:alerts).and_return(alerts)
      end

      it 'runs checks, not activates alerts and not sends emails' do
        expect(dependencies_updater_instance).to receive(:call)
          .and_return(nil)
        expect(trigger.alerts.map(&:active)).to all(be_falsey)

        triggers_checker.call
        expect(trigger.alerts.map(&:active)).to all(be_falsey)
      end
    end
  end
end
