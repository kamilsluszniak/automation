# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { described_class.new }

    it 'validates name, user, permission_type presence', :aggregate_failures do
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:name]).to eq(["can't be blank"])
      expect(subject.errors[:user]).to eq(['must exist'])
      expect(subject.errors[:permission_type]).to eq(["can't be blank"])
    end
  end
end
