# frozen_string_literal: true

FactoryBot.define do
  factory :trigger do
    name { 'basic trigger' }
    device_name { 'my_device' }
    metric { 'my_metric' }
    operator { '<' }
    value { 10 }
    type { '' }
    enabled { true }
  end
end
