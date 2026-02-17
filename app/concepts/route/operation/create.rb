class Route::Operation::Create < Trailblazer::Operation
  step Model(::Route, :new)
  step :initialize_view_count!
  step :assign_current_user!
  step Contract::Build(constant: Route::Contract::Create)
  step Contract::Validate(key: :route)
  step :process_google_items
  step :process_tags!
  step Contract::Persist()
  step :notify_followers!

  def assign_current_user!(options, model:, current_user:, **)
    model.user = current_user
  end

  def initialize_view_count!(ctx, model:, **)
      model.view_count = 0
  end
  
  def notify_followers!(ctx, model:, **)
    NotificationService.notify_new_route_from_following(model)
    true
  rescue => e
    Rails.logger.error("Notificaiton failed: #{e.message}")
    true
  end

def process_google_items(options, params:, model:, **)
  items = params[:route_items] || (params[:route] && params[:route][:route_items_attributes]) || (params[:route] && params[:route][:route_items])
  return true if items.blank?

  items.each_with_index do |item, index|
    # Пропускаем, если название места пустое
    next if item['venue_name'].blank?

    model.route_items.build(
      venue_name:       item['venue_name'],
      venue_address:    item['venue_address'],
      duration_minutes: item['duration_minutes'],
      order_index:      index,
      position:         index + 1,
      item_type:        "Venue"
    )
  end
  true
end

def process_tags!(options, params:, model:, **)
  if params[:route] && params[:route][:tag_ids].present?
    model.tag_ids = params[:route][:tag_ids].reject(&:blank?)
  end
  true
end
end
