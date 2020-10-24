# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Automation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.eager_load_paths += [Rails.root.join('lib')]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W[#{config.root}/app/models/devices]
    config.autoload_paths += %W[#{config.root}/lib]
    require Rails.root.join('lib/jsonwebtoken')
    Dir[Rails.root.join('lib/notifiers/*.rb')].sort.each { |file| require file }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://your.frontend.domain.com'
        resource '/api/*',
          headers: %w(Authorization),
          methods: :any,
          expose: %w(Authorization),
          max_age: 600
      end
    end
  end
end
