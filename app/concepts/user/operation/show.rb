module User::Operation
  class Show < Trailblazer::Operation
    step Model(User, :find_by)
    step :set_routes!
    step :set_saved_routes!
    step :set_activities!
    step :fetch_routes!

    def set_routes!(ctx, model:, current_user:, **)
      # Показываем скрытые маршруты только владельцу профиля
      scope = (current_user == model) ? model.routes : model.routes.public_routes
      ctx[:routes] = scope.includes(:city, :tags, :route_items)
                          .with_attached_images
                          .order(created_at: :desc)
                          .limit(20)
    end

  def set_saved_routes!(ctx, model:, **)
    ctx[:saved_routes] = model.bookmarks
                              .includes(item: [:user, :city,  :route_items, { photos_attachments: :blob }]) 
                              .order(created_at: :DESC)
                              .limit(20)

  end

    def set_activities!(ctx, model:, params:, **)
      ctx[:activities] = model.activities
      .includes(
        :user, 
        trackable: [:following,
                    likeable: [:city],
                    item: [:city]
                    ]
                  ) 
      .order(created_at: :desc)
      .page(params[:activity_page])
      .per(10)
    end
    
  def fetch_routes!(ctx, model:, **)
    # Загружаем маршруты автора со всеми связями сразу
    ctx[:routes] = model.routes
                        .includes(:city, :user, :route_items) 
                        .with_attached_images
                        .recent
                        .limit(20)
  end
  end
end