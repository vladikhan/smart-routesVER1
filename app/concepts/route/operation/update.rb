module Route::Operation
  class Update < Trailblazer::Operation
    # Операция Present нужна для инициализации формы в контроллере (action :edit)
    class Present < Trailblazer::Operation
      step :model!
      step :check_ownership!
      step Contract::Build(constant: Route::Contract::Update)

      def model!(ctx, params:, **)
        ctx[:model] = ::Route.find_by(id: params[:id])
      end

      def check_ownership!(ctx, current_user:, model:, **)
        return true if model&.user_id == current_user.id || current_user&.is_admin?
        ctx[:error] = 'アクセス権限がありません'
        false
      end
    end

    # --- Основные шаги PATCH/PUT запроса ---
    step :model!
    step :check_ownership!
    step Contract::Build(constant: Route::Contract::Update)
    step Contract::Validate(key: :route)
    step :process_route_items!
    step :persist_images! # Добавил из твоего старого кода, чтобы картинки не терялись
    step Contract::Persist()
    step :update_tags!
    step :log_activity!

    # --- Методы реализации ---

    def model!(ctx, params:, **)
      ctx[:model] = ::Route.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      ctx[:error] = "Маршрут не найден"
      false
    end

    def check_ownership!(ctx, current_user:, model:, **)
      return true if model.user_id == current_user.id || current_user&.is_admin?
      
      ctx[:error] = 'アクセス権限がありません'
      false
    end


def process_route_items!(ctx, params:, model:, **)
  route_data = params[:route] || {}
  items_data = route_data[:route_items_attributes] || {}
  items_array = items_data.is_a?(Hash) ? items_data.values : items_data

  # Удаляем старые
  model.route_items.destroy_all

  items_array.each_with_index do |item_params, index|
    next if item_params["venue_name"].blank?

    # Создаем через create!, чтобы если упадет - мы увидели ошибку в логах сразу
    model.route_items.create!(
      venue_name:    item_params["venue_name"],
      venue_address: item_params["venue_address"],
      geo_lat:       item_params["venue_lat"].to_f,
      geo_lng:       item_params["venue_lng"].to_f,
      position:      index
    )
  end
  true
rescue => e
  # Если что-то упадет, мы увидим это в консоли сервера!
  Rails.logger.error "!!! ERROR SAVING ITEMS: #{e.message}"
  ctx[:error] = e.message
  false 
end

    def persist_images!(ctx, model:, params:, **)
      # Сохраняем логику загрузки картинок из твоего старого кода
      return true unless params[:route] && params[:route][:images]
      
      new_images = params[:route][:images]
      images_to_add = Array(new_images).reject(&:blank?)
      model.images.attach(images_to_add) if images_to_add.any?
      true
    end

    def update_tags!(ctx, params:, model:, **)
      return true unless params[:route] && params[:route][:tag_ids].present?
      
      tag_ids = params[:route][:tag_ids].reject(&:blank?).map(&:to_i)
      model.tag_ids = tag_ids
      true
    end

    def log_activity!(ctx, current_user:, model:, **)
      Activity.create!(
        user: current_user,
        trackable: model,
        key: 'route.update'
      )
      true
    rescue => e
      Rails.logger.error("[Route::Update] Activity log failed: #{e.message}")
      true # Лог не должен «валить» всю операцию
    end
  end
end