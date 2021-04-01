# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      # rubocop:disable Metrics/AbcSize
      def create
        build_resource(sign_up_params)

        resource.save
        yield resource if block_given?
        if resource.persisted?
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
            respond_with resource
            # else
            #   expire_data_after_sign_in!
            #   respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        else
          # clean_up_passwords resource
          # set_minimum_password_length
          # respond_with resource
          render json: resource.errors, status: :unprocessable_entity
        end
      end
      # rubocop:enable Metrics/AbcSize

      private

      def respond_with(resource, _opts = {})
        render json: UserSerializer.new(resource)
      end

      def sign_up_params
        params.require(:user).permit(:name, :email, :password)
      end
    end
  end
end
