# frozen_string_literal: true

module Triggers
  class DependenciesUpdater
    def initialize(user:, trigger:, is_triggered:)
      @user = user
      @trigger = trigger
      @dependencies = trigger.dependencies.with_indifferent_access
      @state = is_triggered ? :triggered : :not_triggered
    end

    def call
      return unless dependencies

      dependent_devices.each do |device|
        store_original_settings_in_not_triggered(device) if state == :triggered && should_keep_original(device)
        device.update(
          settings: extract_original_settings(
            dependencies[:devices][device.name][state]
          )
        )
      end
    end

    private

    attr_reader :trigger, :state, :user
    attr_accessor :dependencies

    def should_keep_original(device)
      dependencies[:devices][device.name][:not_triggered].key? :original_settings
    end

    # rubocop:disable Metrics/AbcSize
    def store_original_settings_in_not_triggered(device)
      return if dependencies[:devices][device.name][:not_triggered][:original_settings]

      dependencies[:devices][device.name][:not_triggered][:original_settings] = device.settings
      trigger.update(dependencies: dependencies.deep_symbolize_keys)
    end
    # rubocop:enable Metrics/AbcSize

    def dependent_devices
      device_names = dependencies[:devices]&.keys
      user.devices.where(name: device_names)
    end

    def extract_original_settings(settings)
      return settings unless settings.key? :original_settings

      settings[:original_settings]
    end
  end
end
