module Route::Contract
  class Create < Reform::Form
    property :name
    property :description
    property :city_id
    property :estimated_cost
    property :estimated_duration
    property :is_public
    property :tag_list # Для тегов

    # Вложенные элементы маршрута
    collection :route_items, populate_if_empty: RouteItem do
      property :venue_id
      property :name
      property :latitude
      property :longitude
      property :order_index
      property :description
    end

    validates :name, presence: true
    validates :city_id, presence: true
    validate :acceptable_images
    
    def acceptable_images
      return unless images.attached?

      images.each do |image|
        errors.add(:images, 'は5MB以下である必要があります') unless image.byte_size <= 5.megabytes
      end

      acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
      return if acceptable_types.include?(image.content_type)

      errors.add(:images, 'はJPEG, PNG, GIF形式である必要があります')
    end
  end
end
