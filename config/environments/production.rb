require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # --- SECURITY & NETWORK ---
  config.action_controller.default_protect_from_forgery = false
  config.force_ssl = false # ALB терминирует SSL, Rails видит HTTP
  config.eager_load = true

  # Разрешаем все хосты для стабильной работы ALB Health Checks и домена
  config.hosts.clear
  config.hosts << /.*/ 

  # --- ERROR HANDLING & CACHING ---
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = true
  config.assets.compile = false # Ассеты должны быть скомпилированы при сборке Docker
  
  # --- STORAGE & LOGS ---
  config.active_storage.service = :amazon
  config.log_level = :info
  config.log_tags = [:request_id]

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = ::Logger::Formatter.new
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # --- MAIL SETTINGS (The Fix) ---
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  config.action_mailer.smtp_settings = {
    address:              ENV['SMTP_ADDRESS'],     # 'smtp.gmail.com'
    port:                 ENV['SMTP_PORT'],        # 587
    domain:               ENV['SMTP_DOMAIN'],      # 'smartroutes.learning.datora.org'
    user_name:            ENV['SMTP_USERNAME'],    # Твой Gmail
    password:             ENV['SMTP_PASSWORD'],    # Твой App Password
    authentication:       'plain',
    enable_starttls_auto: true
  }

  config.action_mailer.default_url_options = {
    host: 'smartroutes.learning.datora.org',
    protocol: 'https'
  }

  # --- DEPRECATIONS & I18N ---
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.dump_schema_after_migration = false
end