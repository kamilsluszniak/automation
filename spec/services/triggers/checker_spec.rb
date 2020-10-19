# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Triggers::Checker, type: :model do
  context 'when triggers and alerts exist' do
    let(:user) { create(:user) }
    let(:alerts) { create_list(:alert, 2, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: alerts) }

    it 'runs checks and activates alerts when condition triggers them and sends emails' do
      allow_any_instance_of(Reports).to receive(:read_data_points) do
        [
          {
            'name' => 'time_series_1',
            'tags' => { 'region' => 'uk' },
            'values' => [
              { 'time' => '2015-07-09T09:03:31Z', 'count' => 32, 'value' => 0.9673 }
            ]
          }
        ]
      end
      expect(trigger.alerts.map(&:active)).to all(be_falsey)
      expect do
        Triggers::Checker.new.call
      end.to change {
        ActionMailer::Base.deliveries.count
      }.by(2)

      expect(trigger.reload.alerts.map(&:active)).to all(be_truthy)
    end

    it 'runs checks and not activates alert when condition not triggers it' do
      allow_any_instance_of(Reports).to receive(:read_data_points) do
        [
          {
            'name' => 'time_series_1',
            'tags' => { 'region' => 'uk' },
            'values' => [
              { 'time' => '2015-07-09T09:03:31Z', 'count' => 32, 'value' => 11 }
            ]
          }
        ]
      end
      expect(trigger.alerts.map(&:active)).to all(be_falsey)

      Triggers::Checker.new.call
      expect(trigger.reload.alerts.map(&:active)).to all(be_falsey)
    end
  end
end
