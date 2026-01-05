require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Основные настройки
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  # Кэширование
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Active Storage
  config.active_storage.service = :local

  # Разрешаем Docker IP диапазоны
  config.action_dispatch.trusted_proxies = [
    '127.0.0.1',
    '::1',
    /^172\.\d{1,3}\.\d{1,3}\.\d{1,3}$/,
    /^192\.168\.\d{1,3}\.\d{1,3}$/
  ]

  # Разрешаем Web Console для Docker
  config.web_console.permissions = [
    '127.0.0.1',
    '::1',
    '172.16.0.0/12',
    '192.168.0.0/16', # Это убирет ошибку "Cannot render console"
    '10.0.0.0/8' #  for AWS
  ]

  # Подробное логирование для debugging
  config.log_level = :debug
  config.hosts << '192.168.10.22'
  config.hosts << 'localhost'
  config.hosts << '.local'
  config.hosts << /172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+/
  config.log_level = :debug
  # Action Mailer для разработки
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
<<<<<<< HEAD
  config.action_mailer.default_url_options = { host: '52.195.115.255' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
=======
  
  

  
>>>>>>> 55a4fc27c4a92ea4f8629cf866c6509ccbbf0fad

  # Логи и отладка
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.assets.debug = true
  config.assets.quiet = true
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

<<<<<<< HEAD
  # Настройки для Gmail SMTP
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'gmail.com',
    user_name: 'v.khan@datora.jp',
    password: 'hmbuzoihkvfchhus',
    authentication: 'plain',
    enable_starttls_auto: true
  }
=======
    config.action_mailer.perform_deliveries = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = { host: '52.195.115.255' }
    config.hosts << "smartroutes.learning.datora.org"
    config.hosts << "52.195.115.255"
    config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'gmail.com',
      user_name:            ENV['GMAIL_USERNAME'],
      password:             ENV['GMAIL_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true
    } 
  
>>>>>>> 55a4fc27c4a92ea4f8629cf866c6509ccbbf0fad
end
