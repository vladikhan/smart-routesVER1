module Route::Operation
  class Show < Trailblazer::Operation
    step :model!
    step :increment_views!
    step :related_routes!
    step :fetch_interactions!
    step :map_items!

    def model!(ctx, params:, **)
      # Подгружаем route_items и их items (venues) сразу
      ctx[:model] = Route.includes(route_items: :item).find_by(id: params[:id])
    end

    def increment_views!(ctx, model:, **)
      # Используем update_columns, чтобы не триггерить валидации и коллбеки (это быстрее)
      model.increment_view_count! if model&.persisted?
      true
    end

    def fetch_interactions!(ctx, model:, current_user:, **)
      return true unless current_user
      
      # ОПТИМИЗАЦИЯ: Вместо liked? и bookmarked? (которые делают SELECT EXISTS),
      # мы просто ищем сами объекты. Если они есть — значит лайк/закладка стоит.
      ctx[:user_like]     = current_user.likes.find_by(likeable: model)
      ctx[:user_bookmark] = current_user.bookmarks.find_by(item: model)
      
      # Теперь булевы значения берем из наличия объектов (0 запросов в базу)
      ctx[:current_user_liked]      = ctx[:user_like].present?
      ctx[:current_user_bookmarked] = ctx[:user_bookmark].present?
      
      # Фоллловинг оставляем как есть, если это частый запрос
      ctx[:current_user_following]  = current_user.following?(model.user)
      true
    end

    def related_routes!(ctx, model:, **)
      # Здесь всё отлично, includes(:route_items) уберет N+1 в карточках
      ctx[:related_routes] = ::Route.where(city_id: model.city_id)
                                    .where.not(id: model.id)
                                    .where(is_public: true)
                                    .includes(:route_items)
                                    .limit(3)
    end

    def map_items!(ctx, model:, **)
      # Твой фикс с .to_a — супер. Данные берутся из памяти.
      ctx[:map_items] = model.route_items.to_a.sort_by(&:position).map do |ri|
        {
          name:    ri.venue_name,
          lat:     ri.latitude.to_f, 
          lng:     ri.longitude.to_f,
          address: ri.venue_address
        }
      end
    end
  end
end