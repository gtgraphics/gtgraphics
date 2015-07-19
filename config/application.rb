require File.expand_path('../boot', __FILE__)

require 'rails/all'
require './lib/router/middleware'
require './lib/router/error_handler'
require './lib/router/error_handler/middleware'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module GtGraphics
  class Application < Rails::Application
    # Load some middlewares
    config.middleware.use 'Rack::EncodingGuard::Middleware', :reject
    config.middleware.use 'Router::Middleware'
    config.middleware.use 'JQuery::FileUpload::Rails::Middleware'
    config.exceptions_app = Router::ErrorHandler::Middleware.new

    # Autoload files in root of lib folder
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app', 'presenters', 'concerns')
    config.autoload_paths << Rails.root.join('app', 'uploaders', 'concerns')
    config.autoload_paths << Rails.root.join('app', 'services', 'concerns')

    config.active_record.raise_in_transactional_callbacks = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.available_locales = [:de, :en]
    config.i18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = { en: [:en, :de], de: [:de, :en] }
  end
end

Globalize.fallbacks = { en: [:en, :de], de: [:de, :en] }
