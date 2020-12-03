# frozen_string_literal: true

class ApiKey < ApplicationRecord
  belongs_to :user

  enum permission_type: { read: 0, read_write: 1, admin: 2 }

  validates :name, :permission_type, presence: true

  before_validation :set_key, on: :create

  private

  def set_key
    self.key = SecureRandom.urlsafe_base64(24)
  end
end
