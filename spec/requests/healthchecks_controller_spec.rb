# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthchecksController, type: :request do
  context 'with no authentication' do
    it 'gets ping with status ok' do
      get '/ping'
      assert_equal response.status, 200
    end
  end
end
