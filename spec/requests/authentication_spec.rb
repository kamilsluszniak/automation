# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /users/sign_in', type: :request do
  let(:user) { create(:user) }
  let(:params) do
    {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  context 'when params are correct' do
    let(:headers) { { 'Accept' => 'application/json' } }

    it 'returns 200' do
      post user_session_path, params: params, :headers => headers
      expect(response).to have_http_status(200)
    end

    it 'returns JWT in authorization header' do
      post user_session_path, params: params, :headers => headers
      expect(response.headers['Authorization']).to be_present
    end
  end

  context 'when login params are incorrect' do
    before { post user_session_path }

    it 'returns unathorized status' do
      expect(response.status).to eq 401
    end
  end
end
