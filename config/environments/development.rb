require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # --- Инфраструктура ---
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  # --- Настройка Active Storage ---
  # Указываем использовать сервис 'local' из config/storage.yml
  config.active_storage.service = :local

  # Процессор изображений (оставь vips, если он есть в Docker, или закомментируй пока)
  # config.active_storage.variant_processor = :vips

  # --- Настройка REDIS (Docker Ready) ---
  # Используем порт 6379, как в твоем docker-compose.yml
  redis_url = ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' }

  # Настраиваем cache_store на Redis ВСЕГДА.
  # perform_caching просто определяет, будет ли Rails записывать туда фрагменты видов.
  config.cache_store = :redis_cache_store, { url: redis_url }

  config.action_controller.perform_caching = (Rails.root.join('tmp/caching-dev.txt').exist? || false)

  # Сессии: используем встроенный в Rails механизм через cache_store (Redis)
  config.session_store :cache_store, key: '_smartroutes_session'

  # --- Очереди Sidekiq ---
  # Указываем Rails использовать Sidekiq для фоновых задач
  config.active_job.queue_adapter = :sidekiq

  # --- Почта (GMAIL через ENV) ---
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'gmail.com',
    user_name: ENV['GMAIL_USERNAME'],
    password: ENV['GMAIL_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  # --- Разрешенные хосты (для Docker и AWS) ---
  config.hosts << 'smartroutes.learning.datora.org'
  config.hosts << '52.195.115.255'
  config.hosts << 'localhost'
  config.hosts << 'web' # Важно для обращения внутри сети Docker
  config.hosts << /.*\.amazonaws\.com/

  # --- Безопасность и Web Console ---
  config.action_dispatch.trusted_proxies = ['127.0.0.1', '::1', /^172\./, /^192\.168\./]
  config.web_console.permissions = ['127.0.0.1', '::1', '172.16.0.0/12', '192.168.0.0/16', '10.0.0.0/8']

  # --- Логирование ---
  config.log_level = :debug
  config.active_record.verbose_query_logs = true
  config.assets.debug = true
end
