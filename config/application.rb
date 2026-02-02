require_relative 'boot'

require 'rails/all'
require 'logger'

Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.hosts.clear

    config.load_defaults 6.1

    config.active_storage.replace_on_assign_to_many = false

    config.autoload_paths << Rails.root.join('app', 'concepts')

    # Set default locale to Japanese
    config.i18n.default_locale = :ja

    # Optional: fallback to English if translation is missing
    config.i18n.fallbacks = [:en]
  end
end
