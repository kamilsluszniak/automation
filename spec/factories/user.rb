# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password { 'password' }
    password_confirmation { 'password' }
  end
end
