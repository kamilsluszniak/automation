# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    name { 'cool_device' }
    turn_on_time { 3.hours.ago.to_i }
    turn_off_time { 4.hours.from_now.to_i }
    intensity { { 658 => { red: 10, green: 40, blue: 0, white: 10 } } }
    on { true }
    type { 'Light' }
    light_intensity_lvl { 1 }
  end

  factory :aquarium_controller do
    name { 'aquarium_controller' }
    turn_on_time { 3.hours.ago.to_i }
    turn_off_time { 4.hours.from_now.to_i }
    intensity { { 658 => { red: 10, green: 40, blue: 0, white: 10 } } }
    on { true }
    distance { 200 }
    type { 'AquariumController' }
    light_intensity_lvl { 1 }
    connected_devices { { 'water_input_valve' => '192.168.2.108' } }
  end

  factory :valve_controller do
    name { 'valve_controller' }
    turn_on_time { 3.hours.ago.to_i }
    turn_off_time { 4.hours.from_now.to_i }
    intensity { { 658 => { red: 10, green: 40, blue: 0, white: 10 } } }
    on { false }
    type { 'ValveController' }
  end
end
