# frozen_string_literal: true

module Api
  module V1
    class MeasurementsController < Api::V1::BaseController
      before_action :set_user_by_key
      before_action :authenticate_user!, unless: -> { @api_key.present? }

      def create
        formatted_measurements = extract_formatted_measurements
        result = write_measurements(formatted_measurements)

        if result.code == '204'
          run_triggers_checker(formatted_measurements)
          return render json: { message: 'success' }, status: :ok
        end

        render json: { message: 'error' }, status: :bad_request
      end

      private

      def extract_formatted_measurements
        filtered_measurements = device_measurements.except('checkin')
        filtered_measurements.to_h.collect { |k, v| { k => v } }
      end

      def write_measurements(formatted_measurements)
        writer.call(formatted_measurements)
      end

      def writer
        @writer ||= Measurements::Writer.new(device.name, device.id, current_user.id)
      end

      def run_triggers_checker(reports_measurements)
        triggers_checker = Triggers::Checker.new(reports_measurements, device.name, current_user)
        triggers_checker.call
      end

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
