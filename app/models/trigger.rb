# frozen_string_literal: true

class Trigger < ApplicationRecord
  has_ancestry primary_key_format: %r{\A[\w\-]+(/[\w\-]+)*\z}
  belongs_to :user
  has_many :alerts_triggers, dependent: :destroy
  has_many :alerts, through: :alerts_triggers
  # rubocop:disable Rails/InverseOf
  has_many :child_triggers, class_name: 'Trigger', foreign_key: 'ancestry',
                            dependent: :nullify
  # rubocop:enable Rails/InverseOf
  belongs_to :device, optional: true
  serialize :dependencies, Hash

  def triggered?
    get_value&.send(operator, value)
  end

  def measurements_reader
    @measurements_reader ||= Measurements::Reader.new(device)
  end

  def get_value(minutes_ago: 1)
    data_points = measurements_reader.call(metric, minutes_ago: minutes_ago)
    data_points.dig(0, 'values', 0, 'value')
  end
end
