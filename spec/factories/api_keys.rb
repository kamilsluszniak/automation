# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    association :user
    name { 'Device key' }
    permission_type { :read_write }
  end
end
