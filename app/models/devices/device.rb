# frozen_string_literal: true

class Device < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged finders]

  validates :type, inclusion: { in: %w[AquariumController Light ValveController] }

  serialize :intensity, Hash
  serialize :intensity_override, Hash
  serialize :connected_devices, Hash
  belongs_to :user
  has_many :charts, dependent: :destroy

  def report_metrics(metrics_array)
    Reports.new(name).write_data_points(metrics_array)
  end

  def get_metrics(metric_name, time_ago = 24, unit = 'h')
    data_points = Reports.new(name).read_data_points(metric_name, time_ago, unit).first
    reports = data_points ? data_points.values[2] : []
    reports.map { |d| [Time.zone.at(d['time']).to_s(:time), d[metric_name]] }
  end

  def show_actual_intensity
    return intensity_override unless intensity_override.empty?

    time_in_minutes = minutes_of_day(Time.zone.now)
    latest_intensity = {}

    intensity.sort.reverse.each do |element|
      latest_intensity = element.last
      break if element.first <= time_in_minutes
    end

    scale_intensity_points(latest_intensity, intensity_scale_factor)
  end

  def add_intensity(time, intensity)
    minutes = time.min + time.hour * 60
    intensity = self.intensity.merge(minutes => intensity)
    update(intensity: intensity.sort.to_h)
  end

  def co2valve_on?
    minutes = Time.zone.now.min + Time.zone.now.hour * 60
    co2valve_on_time <= minutes && co2valve_off_time >= minutes
  end

  def send_update_request(param, json_data)
    return unless current_sign_in_ip

    `curl -X POST -H 'content-type: application/json' -d '#{json_data}' #{current_sign_in_ip}/update_#{param}`
  end

  def permitted_settings
    settings = base_settings
    settings.merge!(intensity: show_actual_intensity) unless intensity_override.blank? && intensity.blank?
    settings.merge!(co2valve_on: co2valve_on?) if co2valve_on_time && co2valve_off_time
    settings
  end

  def base_settings
    attributes.deep_symbolize_keys.except(*hidden_fields) if defined? hidden_fields
  end

  private

  def intensity_scale_factor
    light_intensity_lvl.to_i
  end

  def scale_intensity_points(intensity_hash, scale_factor)
    intensity_hash.each { |k, v| intensity_hash[k] = (scale_factor * v).ceil.to_i }
  end

  def minutes_of_day(time)
    time.hour * 60 + time.min
  end
end
