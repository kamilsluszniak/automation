# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        super { |resource| @resource = resource }
      end

      private

      def respond_with(resource, _opts = {})
        render json: UserSerializer.new(resource).serialized_json
      end

      def respond_to_on_destroy
        head :ok
      end
    end
  end
end
