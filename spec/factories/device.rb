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

    trait :dynamic_time do
      time_zone { 'Warsaw' }
      settings do
        {
          light_intensity: {
            time_dependent: true,
            values: {
              600 => {
                red: 10,
                green: 40
              },
              660 => {
                red: 20,
                green: 50
              },
              720 => {
                red: 0,
                green: 0
              }
            }
          },
          water_height: 300
        }
      end
    end

    trait :complex_not_grouped_settings do
      settings do
        {
          pump1_on: false,
          co2_on: {
            time_dependent: true,
            values: {
              540 => true,
              1260 => false
            }
          },
          pump2_on: {
            time_dependent: true,
            values: {
              1 => true,
              3 => false,
              11 => true,
              13 => false
            },
            override: nil
          }
        }
      end
    end
  end
end
