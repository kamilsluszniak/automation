# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    association :user
    name { 'cool_device' }
    settings do
      {
        light_intensity: {
          time_dependent: true,
          override: {
            red: 100,
            green: 400
          },
          values: {
            600 => {
              red: 10,
              green: 40
            },
            700 => {
              red: 20,
              green: 50
            },
            800 => {
              red: 0,
              green: 0
            }
          }
        },
        water_height: 300
      }
    end
  end
end
