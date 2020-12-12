# frozen_string_literal: true

namespace :triggers do
  desc 'runs trigger checker which fires alerts'
  task check_all: :environment do
    Triggers::Checker.new.call
  end
end
