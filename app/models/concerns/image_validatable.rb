module ImageValidatable
  extend ActiveSupport::Concern

  included do
    validate :acceptable_images
  end

  private

  def acceptable_images
    return unless images.attached?

    images.each do |image|
      errors.add(:images, 'は5MB以下である必要があります') if image.byte_size > 5.megabytes

      acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
      errors.add(:images, 'はJPEG, PNG, GIF形式である必要があります') unless acceptable_types.include?(image.content_type)
    end
  end
end
