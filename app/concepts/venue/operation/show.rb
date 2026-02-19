class Venue::Operation::Show < Trailblazer::Operation
  step :model!
  step :increment_stats!
  step :fetch_related_data!

  def model!(ctx, params:, **)
    ctx[:model] = Venue.find_by(id: params[:id])
  end

  def increment_stats!(ctx, model:, **)
    
    Venue.where(id: model.id).update_all("view_count = COALESCE(view_count, 0) + 1")
    true
  end

  def fetch_related_data!(ctx, model:, **)
  # 1. Находим публичные маршруты, содержащие это заведение
  # Используем distinct, чтобы маршрут не дублировался
  ctx[:public_routes] = Route.where(is_public: true)
                      .joins(:route_items)
                      .where(route_items: { venue_id: model.id })
                      .distinct
                      .includes(:route_items)
                      .order(created_at: :desc)
                      .limit(5)

  # 2. Находим основной (featured) маршрут
  # Берем самый первый из найденных выше (самый свежий публичный)
  ctx[:featured_route] = ctx[:public_routes].first

  # 3. Элементы этого маршрута для карты
  # Используем &. (safe navigation), на случай если маршрутов нет вообще
  ctx[:route_items] = ctx[:featured_route]&.route_items&.includes(:item) || []
end
end