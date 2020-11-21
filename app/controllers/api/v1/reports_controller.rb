# frozen_string_literal: true

module Api
  module V1
    class ReportsController < Api::V1::BaseController
      before_action :authenticate_user!

      def create
        filtered_reports = device_reports.except('checkin')
        reports_array = filtered_reports.to_h.collect { |k, v| { k => v } }
        device.report_metrics(reports_array) unless reports_array.empty?
        # my_logger = Logger.new("#{Rails.root}/log/my.log")
        # my_logger.info("Settings: #{device.permitted_settings.compact.to_s}")
        render json: { settings: device.permitted_settings.compact }, status: :ok
      end

      private

      def params_report_name
        params.dig(:device, :reports, :name)
      end

      def device_params
        params.require(:device).permit(
          :authentication_token, :name, :turn_on_time, :turn_off_time,
          :intensity, :on_temperature, :off_temperature, :on_volume,
          :off_volume, :group, :temperature_set, :status, :on
        )
      end

      def device_reports
        params.require(:device).require(:reports).permit(:checkin, :temperature, :volume, :test, :distance)
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
