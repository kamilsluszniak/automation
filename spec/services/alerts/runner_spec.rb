# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alerts::Runner, type: :model do
  context 'when triggers and alerts exist' do
    subject(:alerts_runner) { Alerts::Runner.new(trigger, is_triggered) }

    let(:user) { create(:user) }
    let(:trigger) do
      create(
        :trigger,
        user: user,
        alerts: [alert]
      )
    end
    let(:alert) do
      create(
        :alert,
        user: user,
        interval_in_seconds: 60,
        last_sent_at: last_sent_at
      )
    end

    context 'when trigger is triggered' do
      let(:is_triggered) { true }

      context 'when last_sent_at is nil' do
        let(:last_sent_at) { nil }

        it 'sends an alert' do
          expect do
            alerts_runner.call
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(1)
        end
      end

      context 'when it`s after interval_in_seconds passed' do
        let(:last_sent_at) { 61.seconds.ago }

        it 'sends an alert' do
          expect do
            alerts_runner.call
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(1)
        end
      end

      context 'when it`s before interval_in_seconds passed' do
        let(:last_sent_at) { 59.seconds.ago }

        it 'not sends an alert' do
          expect do
            alerts_runner.call
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(0)
        end
      end
    end

    context 'when trigger is not triggered' do
      let(:is_triggered) { false }

      context 'when last_sent_at is nil' do
        let(:last_sent_at) { nil }

        it 'sends an alert' do
          expect do
            alerts_runner.call
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(0)
        end
      end

      context 'when it`s after interval_in_seconds passed' do
        let(:last_sent_at) { 61.seconds.ago }

        it 'not sends an alert' do
          expect do
            alerts_runner.call
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(0)
        end
      end

      context 'when it`s before interval_in_seconds passed' do
        let(:last_sent_at) { 59.seconds.ago }

        it 'not sends an alert' do
          expect do
            alerts_runner.call
          end.to change {
            ActionMailer::Base.deliveries.count
          }.by(0)
        end
      end
    end
  end
end
