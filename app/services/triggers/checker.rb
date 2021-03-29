# frozen_string_literal: true

module Triggers
  class Checker
    def initialize(user)
      @user = user
    end

    def call
      query_data = triggers_to_check.map do |trigger|
        {
          device_id: trigger.device_id,
          metric_name: trigger.metric
        }
      end

      @metrics = measurements_reader.call(query_data, last_only: true)

      triggers_to_check.where(ancestry: nil).each do |trigger|
        is_triggered = triggered?(trigger)

        DependenciesUpdater.new(trigger, is_triggered).call
        Alerts::Runner.new(trigger, is_triggered).call
      end
    end

    private

    attr_reader :user, :metrics

    def metric_value(metric_name, device_id)
      metrics.flatten.find do |metric|
        metric['_field'] == metric_name && metric['device_id'] == device_id
      end&.dig('_value')
    end

    def triggers_to_check
      @triggers_to_check ||= user.triggers.where(enabled: true).includes(:alerts, :child_triggers)
    end

    def triggered?(trigger)
      children = trigger.child_triggers
      is_combined = children.any?

      if is_combined
        triggered = children.map do |child_trigger|
          triggered?(child_trigger)
        end

        case trigger.operator
        when 'AND'
          triggered.all? { |status| status == true }
        when 'OR'
          triggered.any? { |status| status == true }
        end
      else
        check_trigger(trigger)
      end
    end

    def check_trigger(trigger)
      trigger_value = Measurements::StringValuesParser.call(trigger.value)

      checked_value = Measurements::StringValuesParser.call(
        metric_value(trigger.metric, trigger.device_id)
      )

      return false unless checked_value

      checked_value.send(trigger.operator, trigger_value)
    end

    def measurements_reader
      @measurements_reader ||= Measurements::Reader.new(user_id: user.id)
    end
  end
end
