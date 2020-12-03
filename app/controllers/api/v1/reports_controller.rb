# frozen_string_literal: true

module Api
  module V1
    class ReportsController < Api::V1::BaseController
      before_action :set_user_by_key
      before_action :authenticate_user!, unless: -> { @api_key.present? }

      def create
        filtered_reports = device_reports.except('checkin')
        reports_array = filtered_reports.to_h.collect { |k, v| { k => v } }
        device.report_metrics(reports_array) unless reports_array.empty?
        render json: { message: 'success' }, status: :ok
      end

      private

      def params_report_name
        params.dig(:device, :reports, :name)
      end

      def device_params
        params.require(:device).permit(
          :authentication_token, :name, :status, :on
        )
      end

      def device_reports
        params.require(:device).require(:reports).permit!
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
