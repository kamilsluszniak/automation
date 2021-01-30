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
        expect(value).to eq 10
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

      it 'creates instance of Measurements::Reader class' do
        client = trigger.send(:measurements_reader)
        expect(client).to be_an_instance_of(Measurements::Reader)
      end

      it 'gets value' do
        allow_any_instance_of(Measurements::Reader).to receive(:call) do
          [
            { value: 1, time: '2021-01-30T11:49:02.585000000+00:00' },
            { value: 1, time: '2021-01-30T11:49:02.597000000+00:00' },
            { value: 1, time: '2021-01-30T11:49:02.600000000+00:00' },
            { value: 1, time: '2021-01-30T11:49:02.604000000+00:00' }
          ]
        end

        value = trigger.send(:get_value)
        expect(value).to eq 1
      end

      it "doesn't fail when value is empty" do
        allow_any_instance_of(Reports).to receive(:read_data_points) do
          []
        end

        value = trigger.send(:get_value)
        expect(value).to eq nil
      end

      it "doesn't fail when data is empty" do
        allow_any_instance_of(Reports).to receive(:read_data_points) do
          []
        end

        value = trigger.send(:get_value)
        expect(value).to eq nil
      end

      it 'compare trigger value with measurement' do
        allow(trigger).to receive(:get_value) { 5 }
        expected = trigger.triggered?
        expect(expected).to be_truthy # 5 < 10
      end
    end
  end
end
