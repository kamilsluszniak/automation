# frozen_string_literal: true

class Device < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged finders]

  serialize :settings
  belongs_to :user
  has_many :triggers, dependent: :destroy
end
