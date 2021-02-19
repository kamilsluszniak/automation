# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device, type: :model do
  describe 'validations' do
    context 'when user is created' do
      let(:user) { create(:user) }
    end
  end
end
