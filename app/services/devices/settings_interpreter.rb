# frozen_string_literal: true

module Devices
  class SettingsInterpreter
    def initialize(settings)
      @settings = settings
    end

    def call
      process_each_setting
    end

    private

    def process_each_setting
      settings.inject({}) do |memo, (key, val)|
        to_merge = if val.is_a? Hash
                     { key => process_complex(val) }
                   else
                     { key => val }
                   end
        memo.merge(to_merge)
      end
    end

    def process_complex(setting)
      if setting[:override]
        setting[:override]
      elsif setting[:time_dependent]
        get_actual_value(setting[:values])
      else
        {}
      end
    end

    def get_actual_value(setting)
      time_in_minutes = minutes_of_day(Time.zone.now)
      reverse_sorted_settings = setting.sort.reverse
      latest_setting = reverse_sorted_settings.dig(0, 1)
      reverse_sorted_settings.detect { |i| i.first <= time_in_minutes }&.last || latest_setting
    end

    def minutes_of_day(time)
      time.hour * 60 + time.min
    end

    attr_accessor :settings, :processed
  end
end
