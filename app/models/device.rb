# frozen_string_literal: true

class Device < ApplicationRecord
  extend FriendlyId
  self.implicit_order_column = 'created_at'
  friendly_id :name, use: %i[slugged finders]

  serialize :settings
  belongs_to :user
  has_many :triggers, dependent: :destroy

  validates :name, uniqueness: { scope: :user_id }
end
