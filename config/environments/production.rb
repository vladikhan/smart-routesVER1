require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.action_controller.default_protect_from_forgery = false
  config.force_ssl = false
  config.eager_load = true

  # --- СЕКЦИЯ HOSTS (ВАЖНО ДЛЯ HEALTH CHECK) ---

  # config.hosts << /^\d+\.\d+\.\d+\.\d+$/ 
 
  # config.hosts << 'smartroutes.learning.datora.org'
  # config.hosts << "0.0.0.0"                        
  # config.hosts << "127.0.0.1"                      
  # config.hosts << "smartroutes.learning.datora.org" 
  # config.hosts << /.*\.amazonaws\.com/
  # config.hosts << /.*\.internal/
  # config.hosts << /.*\.compute\.internal/
   config.hosts.clear
   config.hosts << /.*/ 
  # ----------------------------------------------

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = true
  config.assets.compile = false
  config.active_storage.service = :amazon
  config.log_level = :info
  config.log_tags = [:request_id]

  config.ssl_options = { hsts: false }
  config.action_mailer.perform_caching = false

  # --- НАСТРОЙКИ ПОЧТЫ ---
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'smartroutes.learning.datora.org',
    user_name: ENV['GMAIL_USERNAME'],
    password: ENV['GMAIL_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true,
    openssl_verify_mode: 'none'
  }

  config.action_mailer.default_url_options = {
    host: 'smartroutes.learning.datora.org',
    protocol: 'https'
  }

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end