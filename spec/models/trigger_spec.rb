# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trigger, type: :model do
  describe 'parsing conditions' do
    context 'when conditions are valid' do
      let(:user) { create(:user) }
      let(:alert) { create(:alert, user: user) }
      let(:trigger) { create(:trigger, user: user, alerts: [alert]) }

      it { should have_many :alerts }
      it { should belong_to :user }

      it 'gets value' do
        value = trigger.send(:value)
        expect(value).to eq '10'
      end

      it 'gets operator' do
        operator = trigger.send(:operator)
        expect(operator).to eq '<'
      end

      it 'gets metric' do
        metric = trigger.send(:metric)
        expect(metric).to eq 'my_metric'
      end

      it 'gets device' do
        device = trigger.send(:device)
        expect(device).to eq 'my_device'
      end
    end
  end
end
