# frozen_string_literal: true

module Api
  module V1
    class DevicesController < Api::V1::BaseController
      before_action :ensure_device, only: %i[show edit update destroy]
      before_action :set_user_by_key, only: %i[show]
      before_action :authenticate_user!, unless: -> { @api_key.present? }

      def show
        render json: DeviceSerializer.new(
          device, params: { current_settings: device_params[:current_settings] }
        ).serializable_hash
      end

      def new; end

      def edit; end

      def create; end

      def update
        device.update(device_params)
        redirect_to device_path(@device.id)
      end

      def destroy; end

      private

      def device_params
        params.permit(:name, :current_settings)
      end

      def device
        @device ||= Device.friendly.find(params[:id])
      end

      def ensure_device
        redirect_to root_path unless device
      end
    end
  end
end
