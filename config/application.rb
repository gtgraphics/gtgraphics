require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module GtGraphics
  class Application < Rails::Application
    config.middleware.use JQuery::FileUpload::Rails::Middleware

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Berlin'

    # Autoload files in root of lib folder
    config.autoload_paths << Rails.root.join('lib').to_s
    config.autoload_paths << Rails.root.join('app', 'presenters', 'concerns').to_s
    config.autoload_paths << Rails.root.join('app', 'uploaders', 'concerns').to_s
    config.autoload_paths << Rails.root.join('app', 'strategies', 'concerns').to_s

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.available_locales = [:de, :en]
    config.i18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = { en: [:en, :de], de: [:de, :en] }
  end
end

Globalize.fallbacks = { en: [:en, :de], de: [:de, :en] }
