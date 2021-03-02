# frozen_string_literal: true

module Triggers
  class Checker
    def initialize(metrics, device_name, user)
      @metrics = metrics
      @device_name = device_name
      @user = user
    end

    def call
      triggers_to_check(metric_names, user).each do |trigger|
        is_triggered = triggered?(trigger)

        DependenciesUpdater.new(trigger, is_triggered).call
        trigger.alerts.each do |alert|
          alert.update(active: is_triggered)
          AlertMailer.alert_triggered_email(alert.user, alert).deliver if alert.active?
        end
      end
    end

    private

    attr_reader :device_name, :metrics, :user

    def metric_names
      metrics.map { |metric| metric.keys.first }
    end

    def metric_value(metric_name)
      metrics.find { |metric| metric.keys.first == metric_name }&.values&.first
    end

    def triggers_to_check(metrics, user)
      user.triggers.where(metric: metrics, device: device_name, enabled: true).includes(:alerts)
    end

    def triggered?(trigger)
      trigger_value = Measurements::StringValuesParser.call(trigger.value)
      checked_value = Measurements::StringValuesParser.call(
        metric_value(trigger.metric)
      )
      checked_value.send(trigger.operator, trigger_value)
    end
  end
end
