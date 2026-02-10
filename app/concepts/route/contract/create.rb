module Route::Contract
  class Create < Reform::Form
    property :name
    property :description
    property :city_id
    property :estimated_cost
    property :estimated_duration
    property :is_public
    # ОБЯЗАТЕЛЬНО ОБЪЯВЛЯЕМ КАРТИНКИ
    property :images 

    # collection :route_items, populate_if_empty: RouteItem do
    #   property :venue_id
    #   property :venue_name
    #   property :venue_address
    #   property :order_index
    #   property :position
    #   property :duration_minutes
    # end

    validates :name, presence: true
    validates :city_id, presence: true
    validate :acceptable_images
    
    def acceptable_images
      # Теперь self.images будет доступен благодаря property :images выше
      # Но так как это ActiveStorage, лучше обращаться к модели напрямую, 
      # если Reform не пробрасывает объект вложения автоматически.
      return unless model.images.attached?

      model.images.each do |image|
        errors.add(:images, 'は5MB以下である必要があります') unless image.byte_size <= 5.megabytes
        
        acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
        unless acceptable_types.include?(image.content_type)
          errors.add(:images, 'はJPEG, PNG, GIF形式である必要があります')
        end
      end
    end
  end
end