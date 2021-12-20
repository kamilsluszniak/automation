# frozen_string_literal: true

module Api
  module V1
    class MeasurementsController < Api::V1::BaseController
      before_action :set_user_by_key
      before_action :authenticate_user!, unless: -> { @api_key.present? }

      def create
        result = write_measurements(extract_formatted_measurements)

        if result.code == '204'
          Triggers::CheckerQueuePublisher.new(user_id: current_user.id).publish
          return render json: { message: 'success' }, status: :ok
        end

        render json: { message: 'error' }, status: :bad_request
      end

      private

      def extract_formatted_measurements
        filtered_measurements = device_measurements.except('checkin')
        filtered_measurements.to_h.collect do |k, v|
          {
            name: k,
            value: v
          }
        end
      end

      def write_measurements(formatted_measurements)
        writer.call(formatted_measurements)
      end

      def writer
        @writer ||= Measurements::Writer.new(device_id: device.id, user_id: current_user.id)
      end

      def run_triggers_checker
        triggers_checker = Triggers::Checker.new(current_user)
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
