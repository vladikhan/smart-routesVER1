module User::Operation
  class Show < Trailblazer::Operation
    step Model(User, :find_by)
    step :set_routes!
    step :set_saved_routes!
    step :set_activities!

    def set_routes!(ctx, model:, current_user:, **)
      # Показываем скрытые маршруты только владельцу профиля
      scope = (current_user == model) ? model.routes : model.routes.public_routes
      ctx[:routes] = scope.includes(:city, :tags)
                          .order(created_at: :desc)
                          .limit(20)
    end

    def set_saved_routes!(ctx, model:, **)
      ctx[:saved_routes] = model.bookmarked_routes
                                .includes(:city, :tags)
                                .order('bookmarks.created_at DESC')
                                .limit(20)
    end

    def set_activities!(ctx, model:, params:, **)
      ctx[:activities] = model.activities 
                              .includes(:trackable)
                              .order(created_at: :desc)
                              .page(params[:activity_page])
                              .per(10)

      
    end
  end
end