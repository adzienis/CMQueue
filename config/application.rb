# frozen_string_literal: true

require_relative "boot"
require "devise"

require "rails/all"

require "action_view"
# require 'haml'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CMQueue
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.autoload_paths << "#{Rails.root}/lib/search"
    config.eager_load_paths += %W[#{Rails.root}/lib/concerns]
    config.active_model.i18n_customize_full_message = true
    config.active_record.schema_format = :sql
    config.time_zone = "Eastern Time (US & Canada)"

    config.hosts << "cmqueue.xyz"
    config.hosts << "localhost"
    config.hosts << "cmqueue-demo.herokuapp.com"
    config.hosts << "192.168.1.183"
    Rails.application.config.action_cable.allowed_request_origins = ["http://cmqueue.xyz", "https://cmqueue.xyz", "https://dev-cmqueue.xyz"]

    # overrides
    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end

    config.general = config_for(:general)

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
