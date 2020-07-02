# frozen_string_literal: true

class Chart < ApplicationRecord
  belongs_to :user
  belongs_to :device
end
