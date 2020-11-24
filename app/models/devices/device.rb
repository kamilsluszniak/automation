# frozen_string_literal: true

class Device < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged finders]

  serialize :settings
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
end
