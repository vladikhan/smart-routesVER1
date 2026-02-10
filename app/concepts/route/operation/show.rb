module Route::Operation
  class Show < Trailblazer::Operation
    step :model!
    step :increment_views!
    step :related_routes!
    step :fetch_interactions!
    step :map_items!

    def model!(ctx, params:, **)
     # Мы загружаем Маршрут + Точки + Заведения одним SQL запросом
      ctx[:model] = Route.includes(route_items: :venue).find_by(id: params[:id])
    end

    def increment_views!(ctx, model:, **)
      model.increment_view_count! if model.persisted?
      true
    end

    def fetch_interactions!(ctx, model:, current_user:, **)
      return true unless current_user # Если не залогинен, просто идем дальше
      
      # Собираем данные об отношениях пользователя с маршрутом
      ctx[:current_user_liked]      = current_user.liked?(model)
      ctx[:current_user_bookmarked] = current_user.bookmarked?(model)
      ctx[:current_user_following]  = current_user.following?(model.user)
      
      # Можно передать и сами объекты лайка/закладки, если нужно ID для удаления
      ctx[:user_like]     = current_user.likes.find_by(likeable: model)
      ctx[:user_bookmark] = current_user.bookmarks.find_by(item: model)
      true
    end

    def related_routes!(ctx, model:, **)
      ctx[:related_routes] = ::Route.where(city_id: model.city_id)
                                        .where.not(id: model.id)
                                        .where(is_public: true)
                                        .limit(3)
    end

    def map_items!(ctx, model:, **)
  ctx[:map_items] = model.route_items.ordered.map do |ri|
    # Пытаемся взять привязанный объект (например, Venue), если он есть
    linked_item = ri.item 

    {
      # Если есть linked_item, берем имя у него. Если нет — берем venue_name из route_item
      name:    linked_item&.respond_to?(:name) ? linked_item.name : ri.venue_name,
      
      # Координаты берем из новых колонок geo_lat/lng, которые мы только что наполнили
      lat:     ri.latitude.to_f,
      lng:     ri.longitude.to_f,
      
      # Адрес аналогично: из объекта или из колонки
      address: linked_item&.respond_to?(:address) ? linked_item.address : ri.venue_address
    }
  end
end
    end
end
