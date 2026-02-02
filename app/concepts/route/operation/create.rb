class Route::Operation::Create < Trailblazer::Operation
  step Model(::Route, :new)
  step :initialize_view_count!
  step :assign_current_user!
  step :process_google_items
  step Contract::Build(constant: Route::Contract::Create)
  step Contract::Validate(key: :route)
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
  end

  def process_google_items!(options, params:, model:, **)
    true unless params[:route][:google_maps_items].present?

    items = JSON.parse(params[:route][:google_maps_items])
    items.each_with_index do |item, index|
      model.route_items.build(
        name: item['name'],
        latitude: item['latitude'],
        longitude: item['longitude'],
        order_index: index,
        description: item['address']
      )
    end
    begin
      true
    rescue StandardError
      true
    end
  end

  def process_tags!(options, params:, model:, **)
    model.tag_list = params[:route][:tag_list].split(',').map(&:strip) if params[:route][:tag_list].present?
    true
  end
end
