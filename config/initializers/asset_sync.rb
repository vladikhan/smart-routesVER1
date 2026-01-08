if defined?(AssetSync)
  AssetSync.configure do |config|
    # Отключаем для development и test
    config.enabled = Rails.env.production?

    # Остальные настройки только для production
    if Rails.env.production?
      config.fog_provider = ENV['FOG_PROVIDER'] || 'AWS'
      config.fog_directory = ENV['FOG_DIRECTORY']
      config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
      config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      config.fog_region = ENV['FOG_REGION'] || 'ap-northeast-1'

      config.existing_remote_files = 'keep'
      config.gzip_compression = true
      config.manifest = true
    end
  end
end
