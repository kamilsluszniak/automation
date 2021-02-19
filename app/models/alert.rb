# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :user
  has_many :alerts_triggers, dependent: :destroy
  has_many :triggers, through: :alerts_triggers
end
