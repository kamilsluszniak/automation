# frozen_string_literal: true

module Alerts
  class Runner
    def initialize(trigger, is_triggered)
      @trigger = trigger
      @is_triggered = is_triggered
    end

    def call
      trigger.alerts.each do |alert|
        alert.update(active: is_triggered)
        send_alert(alert) if alert.active? && alert_ready?(alert)
      end
    end

    private

    attr_reader :trigger, :is_triggered

    def alert_ready?(alert)
      return true unless alert.last_sent_at

      alert.last_sent_at < Time.zone.now - alert.interval_in_seconds
    end

    def send_alert(alert)
      AlertMailer.alert_triggered_email(alert.user, alert).deliver && alert.update(last_sent_at: Time.zone.now)
    end
  end
end
