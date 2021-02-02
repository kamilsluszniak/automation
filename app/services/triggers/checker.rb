# frozen_string_literal: true

module Triggers
  class Checker
    def initialize(metric_name, device_name)
      @metric_name = metric_name
      @device_name = device_name
    end

    def call
      triggers_to_check(metric_name).each do |trigger|
        is_triggered = triggered?(trigger)
        DependenciesUpdater.new(trigger, is_triggered).call
        trigger.alerts.each do |alert|
          alert.update(active: is_triggered)
          AlertMailer.alert_triggered_email(alert.user, alert).deliver if alert.active?
        end
      end
    end

    private

    attr_reader :device_name, :metric_name

    def triggers_to_check(metric)
      Trigger.where(metric: metric).includes(:alerts)
    end

    def triggered?(trigger)
      get_value(trigger)&.send(trigger.operator, trigger.value)
    end

    def get_value(trigger, minutes_ago: 1)
      data_points = Measurements::Reader.new(trigger.device).call(
        trigger.metric, minutes_ago: minutes_ago
      )
      data_points.dig(0, 'values', 0, 'value')
    end
  end
end
