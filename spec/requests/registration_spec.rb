# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/signup', type: :request do
  context 'when params are correct' do
    let(:params) do
      {
        user: {
          name: username,
          email: email,
          password: password
        }
      }
    end
    let(:username) { 'kamil' }
    let(:email) { 'kamil@kamil.kamil' }
    let(:password) { 'mysupersecretpassword' }

    before { post '/api/v1/signup', params: params }

    it 'returns success status' do
      expect(response).to have_http_status(200)
    end

    it 'contains JWT' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'contains provided user data' do
      data = JSON.parse(response.body)['data']
      attributes = data['attributes']
      expect(data['id']).to be_a String
      expect(data['type']).to eq('user')
      expect(attributes['email']).to eq(email)
      expect(attributes['name']).to eq(username)
    end
  end

  context 'when params are incorrect' do
    let(:params) do
      {
        user: {
          name: username,
          email: email,
          password: password
        }
      }
    end
    let(:username) { 'kamil' }

    context 'whem email is invalid' do
      let(:password) { 'mysupersecretpassword' }
      let(:email) { 'thatsnotavalidemail' }

      before { post '/api/v1/signup', params: params }

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(422)
      end

      it 'not contains JWT' do
        expect(response.headers['Authorization']).to be_nil
      end

      it 'contains email error data' do
        errors = JSON.parse(response.body)
        expect(errors['email']).to eq(['is invalid'])
      end
    end

    context 'when password is empty' do
      let(:password) { '' }
      let(:email) { 'kamil@kamil.kamil' }

      before { post '/api/v1/signup', params: params }

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(422)
      end

      it 'not contains JWT' do
        expect(response.headers['Authorization']).to be_nil
      end

      it 'contains password error data' do
        errors = JSON.parse(response.body)
        expect(errors['password']).to eq(["can't be blank"])
      end
    end
  end
end
