# frozen_string_literal: true

module Triggers
  class DependenciesUpdater

    def initialize(trigger)
      @trigger = trigger
      @dependencies = trigger.dependencies.with_indifferent_access
      @state = trigger.triggered? ? :triggered : :not_triggered
    end

    def call
      return unless dependencies

      dependent_devices.each do |device|
        should_keep_original = dependencies[:devices][device.name][:not_triggered].has_key? :original_settings
        if @state == :triggered && should_keep_original
          dependencies[:devices][device.name][:not_triggered][:original_settings] = device.settings
          trigger.update(dependencies: dependencies.deep_symbolize_keys)
        end
        device.update(
          settings: extract_original_settings(
            dependencies[:devices][device.name][state]
          )
        )
      end
    end

    private

    attr_reader :trigger, :state
    attr_accessor :dependencies

    def dependent_devices
      device_names = dependencies[:devices]&.keys
      devices = Device.where(name: device_names)
    end

    def extract_original_settings(settings)
      return settings unless settings.has_key? :original_settings
      settings[:original_settings]
    end
  end
end
