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
    end
  end
end
