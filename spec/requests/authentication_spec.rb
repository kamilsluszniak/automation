# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/login', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Accept' => 'application/json' } }

  context 'when params are correct' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end
    before { post '/api/v1/login', params: params, headers: headers }

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns JWT in authorization header' do
      expect(response.headers['Authorization']).to be_present
    end
  end

  context 'when login params are incorrect' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: 'invalid'
        }
      }
    end
    before { post '/api/v1/login', params: params, headers: headers }

    it 'returns unathorized status' do
      expect(response.status).to eq 401
    end
  end
end
