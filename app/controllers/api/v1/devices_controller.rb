# frozen_string_literal: true

module Api
  module V1
    class DevicesController < Api::V1::BaseController
      before_action :ensure_device, only: %i[show edit update destroy]

      def show
        render json: DeviceSerializer.new(device).serializable_hash
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
        params.require(:device).permit(
          :authentication_token, :name, :turn_on_time, :turn_off_time,
          :intensity, :on_temperature, :off_temperature, :on_volume,
          :off_volume, :group, :temperature_set, :status, :on
        )
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
