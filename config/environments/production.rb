require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

 
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.assets.compile = false

 
  config.active_storage.service = :amazon

  
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  config.force_ssl = false

  config.action_mailer.perform_caching = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'smartroutes.learning.datora.org',
    user_name:            ENV['GMAIL_USERNAME'],
    password:             ENV['GMAIL_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true,
    openssl_verify_mode:  'none'
  }

  config.action_mailer.default_url_options = {
    host: 'smartroutes.learning.datora.org/',
    protocol: 'https'
  }

  
  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.active_support.disallowed_deprecation = :log

  config.active_support.disallowed_deprecation_warnings = []
  
  config.log_formatter = ::Logger::Formatter.new


  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  
end
