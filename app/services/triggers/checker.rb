# frozen_string_literal: true

module Triggers
  class Checker
    def call
      Trigger.includes(:alerts).each do |trigger|
        DependenciesUpdater.new(trigger).call
        trigger.alerts.each do |alert|
          alert.update(active: trigger.triggered?)
          AlertMailer.alert_triggered_email(alert.user, alert).deliver if alert.active?
        end
      end
    end
  end
end
