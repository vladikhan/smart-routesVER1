module Route::Contract
  class Update < Reform::Form
    # --- Свойства (Properties) ---
    property :name
    property :description
    property :city_id
    property :difficulty_level
    property :estimated_duration
    property :estimated_cost
    property :is_public
    
    # Эти поля не сохраняются напрямую в таблицу routes через контракт,
    # а обрабатываются в самой Operation (методы persist_images! и update_tags!)
    property :tags, virtual: true
    property :images, virtual: true

    # --- Валидации (Validations) ---

    # Название маршрута
    validates :name, presence: { message: 'ルート名を入力してください' }
    validates :name, length: { 
      minimum: 3, 
      maximum: 100, 
      too_short: 'ルート名は3文字以上で入力してください',
      too_long: 'ルート名は100文字以内で入力してください'
    }

    # Описание
    validates :description, length: { 
      maximum: 5000,
      too_long: '説明は5000文字以内で入力してください'
    }

    # Город
    validates :city_id, presence: { message: '都市を選択してください' }

    # Сложность (difficulty_level)
    validates :difficulty_level, 
              inclusion: { 
                in: %w[easy medium hard], 
                message: '難易度は「簡単」「普通」「難しい」から選択してください' 
              },
              allow_blank: true

    # Время (estimated_duration)
    validates :estimated_duration, 
              numericality: { 
                greater_than_or_equal_to: 0, 
                message: '所要時間は0以上で入力してください' 
              },
              allow_blank: true

    # Бюджет (estimated_cost)
    validates :estimated_cost, 
              numericality: { 
                greater_than_or_equal_to: 0, 
                message: '予算は0以上で入力してください' 
              },
              allow_blank: true

    # Кастомные валидации для изображений
    validate :images_count_within_limit
    validate :acceptable_images

    private

    # Проверка количества изображений
    def images_count_within_limit
      return unless model.images.attached?
      
      if model.images.count > 10
        errors.add(:images, '画像は最大10枚までアップロードできます')
      end
    end

    # Проверка размера и формата файлов
    def acceptable_images
      return unless model.images.attached?
      
      model.images.each do |image|
        # Проверка размера (5MB)
        unless image.byte_size <= 5.megabytes
          errors.add(:images, "#{image.filename}のサイズが大きすぎます（最大5MB）")
        end
        
        # Проверка расширения (добавили webp и jpg)
        acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
        unless acceptable_types.include?(image.content_type)
          errors.add(:images, "#{image.filename}は対応していない画像形式です")
        end
      end
    end

    def process_route_items!(ctx, params:, model:, **)
  # Берем из params[:route], так как в логах они вложены именно туда
  route_params = params[:route] || params["route"]
  items_params = route_params[:route_items_attributes] || route_params["route_items_attributes"]
  
  return true if items_params.blank?
  
  # Превращаем в массив, если это хэш
  items_to_process = items_params.is_a?(Hash) ? items_params.values : items_params

  model.route_items.destroy_all

  items_to_process.each_with_index do |item_params, index|
    next if item_params["venue_name"].blank?

    model.route_items.build(
      venue_name:    item_params["venue_name"],
      venue_address: item_params["venue_address"],
      geo_lat:       item_params["venue_lat"].to_f,
      geo_lng:       item_params["venue_lng"].to_f,
      position:      index
    )
  end
  true
end
  end
end