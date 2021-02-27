# frozen_string_literal: true

module Api
  module V1
    class MeasurementsController < Api::V1::BaseController
      before_action :set_user_by_key
      before_action :authenticate_user!, unless: -> { @api_key.present? }

      def create
        filtered_measurements = device_measurements.except('checkin')
        measurements_writer = Measurements::Writer.new(device.name, device.id, current_user.id)
        reports_measurements = filtered_measurements.to_h.collect { |k, v| { k => v } }
        result = measurements_writer.call(reports_measurements)
        return render json: { message: 'success' }, status: :ok if result.code == '204'

        render json: { message: 'error' }, status: :bad_request
      end

      private

      def device_measurements
        params.require(:device).require(:measurements).permit!
      end

      def device
        @device ||= current_user.devices.friendly.find(params.dig(:device, :name))
      end

      def ensure_device
        return render json 'No such device', status: 404 unless device
      end
    end
  end
end
