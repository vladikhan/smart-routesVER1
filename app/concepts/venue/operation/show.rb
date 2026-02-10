class Venue::Operation::Show < Trailblazer::Operation
  step :model!
  step :increment_stats!
  step :fetch_related_data!

  def model!(ctx, params:, **)
    # Убираем тяжелые includes, оставляем только саму модель
    ctx[:model] = Venue.find_by(id: params[:id])
  end

  def increment_stats!(ctx, model:, **)
    # Используем update_all, чтобы инкрементировать счетчик в базе данных напрямую
    
    Venue.where(id: model.id).update_all("view_count = COALESCE(view_count, 0) + 1")
    true
  end

  def fetch_related_data!(ctx, model:, **)
    
    ctx[:public_routes] = Route.where(is_public: true)
                               .joins(:route_items)
                               .where(route_items: { venue_id: model.id })
                               .distinct
                               .includes(:route_items)
                               .limit(5)

    # 2. Находим основной (featured) маршрут
    # Лучше искать через связь, чтобы ActiveRecord использовал кэш
    ctx[:featured_route] = model.routes
                                .where(is_public: true)
                                .joins(:route_items)
                                .order('route_items.order_index ASC')
                                .first

    # 3. Элементы этого маршрута (для карты/списка)
    ctx[:route_items] = if ctx[:featured_route]
                          ctx[:featured_route].route_items.includes(:venue)
                        else
                          []
                        end
  end
end