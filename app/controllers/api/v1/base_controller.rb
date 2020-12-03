# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      respond_to :json

      private

      def set_key_by_header
        api_key = request.headers[:HTTP_API_KEY]
        @api_key = ApiKey.find_by(key: api_key) if api_key
      end

      def set_user_by_key
        set_key_by_header
        return unless @api_key

        user = @api_key.user
        sign_in(:user, user)
        user
      end
    end
  end
end
