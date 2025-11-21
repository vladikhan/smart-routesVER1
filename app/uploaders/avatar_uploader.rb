class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Версии изображения
  version :thumb do
    process resize_to_fill: [100, 100]
  end

  version :medium do
    process resize_to_fill: [300, 300]
  end

  # Разрешенные форматы
  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end

  # Имя файла по умолчанию
  def default_url(*args)
    "/images/default_avatar.png"
  end
end