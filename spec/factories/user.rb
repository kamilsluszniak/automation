# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'user@gmail.com' }
    password { 'password' }
    password_confirmation { 'password' }
    name { Faker::Name.name }
  end
end
