# frozen_string_literal: true

class Trigger < ApplicationRecord
  belongs_to :user
  has_many :alerts_triggers, dependent: :destroy
  has_many :alerts, through: :alerts_triggers
  serialize :conditions, Hash
  serialize :dependencies, Hash

  def triggered?
    get_value&.send(operator, value)
  end

  private

  def measurements_reader
    @measurements_reader ||= Measurements::Reader.new(device)
  end

  def value
    conditions[:value]
  end

  def operator
    conditions[:operator]
  end

  def metric
    conditions[:metric]
  end

  def device
    conditions[:device]
  end

  def get_value(minutes_ago: 1)
    data_points = measurements_reader.call(metric, minutes_ago: minutes_ago)
    data_points.dig(0, 'values', 0, 'value')
  end
end
