# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, :validatable, :trackable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :devices, dependent: :destroy
  has_many :charts, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :triggers, dependent: :destroy

  validates :name, presence: true
end
