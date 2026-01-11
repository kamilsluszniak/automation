# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts 'Seeding database...'

# Clear existing data (optional - comment out if you want to keep existing data)
# User.destroy_all

# Create a user
user = User.find_or_create_by!(email: 'demo@example.com') do |u|
  u.name = 'Demo User'
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

puts "Created user: #{user.email}"

# Create devices
devices = [
  {
    name: 'Greenhouse Controller',
    time_zone: 'America/New_York',
    settings: {
      light_intensity: {
        time_dependent: true,
        override: {
          red: 100,
          green: 400
        },
        values: {
          600 => { red: 10, green: 40 },
          700 => { red: 20, green: 50 },
          800 => { red: 0, green: 0 }
        }
      },
      water_height: 300,
      temperature_setpoint: 22.5
    }
  },
  {
    name: 'Hydroponic System',
    time_zone: 'UTC',
    settings: {
      pump1_on: false,
      co2_on: {
        time_dependent: true,
        values: {
          540 => true,
          1260 => false
        }
      },
      ph_level: 6.5,
      nutrient_mix: 'A'
    }
  },
  {
    name: 'Weather Station',
    time_zone: 'America/Los_Angeles',
    settings: {
      sampling_interval: 300,
      alert_thresholds: {
        temperature_high: 30,
        temperature_low: 10,
        humidity_high: 80
      }
    }
  }
]

created_devices = devices.map do |device_attrs|
  device = user.devices.find_or_create_by!(name: device_attrs[:name]) do |d|
    d.time_zone = device_attrs[:time_zone]
    d.settings = device_attrs[:settings]
  end
  puts "Created device: #{device.name}"
  device
end

# Create triggers with dependencies
trigger_configs = [
  {
    name: 'Temperature Too High',
    metric: 'temperature',
    operator: '>',
    value: '28',
    enabled: true,
    device_name: 'Greenhouse Controller',
    dependencies: {
      'Hydroponic System' => {
        triggered: {
          pump1_on: true,
          co2_on: {
            time_dependent: false,
            values: {}
          }
        },
        not_triggered: {
          pump1_on: false
        }
      }
    }
  },
  {
    name: 'Temperature Too Low',
    metric: 'temperature',
    operator: '<',
    value: '15',
    enabled: true,
    device_name: 'Greenhouse Controller',
    dependencies: {
      'Greenhouse Controller' => {
        triggered: {
          light_intensity: {
            time_dependent: false,
            override: {
              red: 255,
              green: 255
            }
          }
        },
        not_triggered: {
          original_settings: nil
        }
      }
    }
  },
  {
    name: 'Water Level Critical',
    metric: 'water_level',
    operator: '<',
    value: '50',
    enabled: true,
    device_name: 'Hydroponic System',
    dependencies: {
      'Hydroponic System' => {
        triggered: {
          pump1_on: true,
          pump2_on: true
        },
        not_triggered: {
          pump1_on: false,
          pump2_on: false
        }
      }
    }
  },
  {
    name: 'Light Intensity Low',
    metric: 'light_intensity',
    operator: '<',
    value: '100',
    enabled: false,
    device_name: 'Greenhouse Controller',
    dependencies: {}
  },
  {
    name: 'Humidity High',
    metric: 'humidity',
    operator: '>',
    value: '85',
    enabled: true,
    device_name: 'Weather Station',
    dependencies: {
      'Hydroponic System' => {
        triggered: {
          co2_on: {
            time_dependent: false,
            values: {
              0 => false
            }
          }
        },
        not_triggered: {
          original_settings: nil
        }
      }
    }
  }
]

created_triggers = trigger_configs.map do |config|
  device = created_devices.find { |d| d.name == config[:device_name] }
  
  # Build dependencies hash
  dependencies = {}
  if config[:dependencies].any?
    dependencies = {
      devices: config[:dependencies].transform_keys(&:to_s)
    }
  end

  trigger = user.triggers.find_or_create_by!(name: config[:name]) do |t|
    t.metric = config[:metric]
    t.operator = config[:operator]
    t.value = config[:value]
    t.enabled = config[:enabled]
    t.device = device
    t.dependencies = dependencies
  end
  puts "Created trigger: #{trigger.name}"
  trigger
end

# Create alerts
alerts = [
  {
    name: 'Critical Temperature Alert',
    active: true,
    interval_in_seconds: 3600
  },
  {
    name: 'Water Level Warning',
    active: true,
    interval_in_seconds: 1800
  },
  {
    name: 'Environmental Monitoring',
    active: false,
    interval_in_seconds: 7200
  }
]

created_alerts = alerts.map do |alert_attrs|
  alert = user.alerts.find_or_create_by!(name: alert_attrs[:name]) do |a|
    a.active = alert_attrs[:active]
    a.interval_in_seconds = alert_attrs[:interval_in_seconds]
  end
  puts "Created alert: #{alert.name}"
  alert
end

# Associate triggers with alerts
# Temperature alert gets temperature triggers
created_alerts[0].triggers = [created_triggers[0], created_triggers[1]]
puts "Associated triggers with alert: #{created_alerts[0].name}"

# Water level alert gets water level trigger
created_alerts[1].triggers = [created_triggers[2]]
puts "Associated triggers with alert: #{created_alerts[1].name}"

# Environmental monitoring gets humidity trigger
created_alerts[2].triggers = [created_triggers[4]]
puts "Associated triggers with alert: #{created_alerts[2].name}"

puts "\nSeeding completed!"
puts "User: #{user.email} (password: password123)"
puts "Devices: #{created_devices.count}"
puts "Triggers: #{created_triggers.count}"
puts "Alerts: #{created_alerts.count}"
