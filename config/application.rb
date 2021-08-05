# frozen_string_literal: true

require_relative 'boot'
require 'devise'

require 'rails/all'

require 'action_view'
require 'haml'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CMQueue
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.autoload_paths << "#{Rails.root}/lib/search"
    config.action_view.raise_on_missing_translations = false
    config.active_model.i18n_customize_full_message = true
    config.active_record.schema_format = :sql

    config.hosts << "cmqueue.xyz"
    Rails.application.config.action_cable.allowed_request_origins = ['http://cmqueue.xyz', 'https://cmqueue.xyz']
    config.to_prepare do
      # Only Applications list
      Doorkeeper::ApplicationsController.layout 'layouts/doorkeeper/application'

      # Only Authorization endpoint
      # Doorkeeper::AuthorizationsController.layout "my_layout"

      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout 'layouts/doorkeeper/admin'
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
