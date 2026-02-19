module Route::Operation
  class Show < Trailblazer::Operation
    step :model!
    step :increment_views!
    step :related_routes!
    step :fetch_interactions!
    step :map_items!

    def model!(ctx, params:, **)
      ctx[:model] = Route.includes(route_items: :item).find_by(id: params[:id])
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
      linked_item = ri.item 

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
