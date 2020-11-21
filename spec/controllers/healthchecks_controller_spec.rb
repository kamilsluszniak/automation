# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthchecksController, type: :controller do
  context 'with no authentication' do
    it 'gets light device settings' do
      get :ping
      assert_equal response.status, 200
    end
  end
end
