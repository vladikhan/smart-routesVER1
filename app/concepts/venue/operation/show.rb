class Venue::Operation::Show < Trailblazer::Operation
  step :model!
  step :increment_stats!
  step :fetch_related_data!

  def model!(ctx, params:, **)
    ctx[:model] = Venue.includes(:routes, :reviews).find_by(id: params[:id])
  end

  def increment_stats!(ctx, model:, **)
    model.increment_view_count
  end

  def fetch_related_data!(ctx, model:, **)
    ctx[:routes] = Route.where(is_public: true)
                        .joins(:route_items)
                        .where(route_items: { venue_id: model.id })
                        .distinct
    ctx[:featured_route] = model.routes.joins(:route_items).order('route_items.order_index ASC').first
    ctx[:route_items]    = ctx[:featured_route] ? ctx[:featured_route].route_items.includes(:venue) : []
    ctx[:public_routes]  = model.routes.where(is_public: true).limit(5) 
  end
end
