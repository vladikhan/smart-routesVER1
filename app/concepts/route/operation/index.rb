module Route::Operation
  class Index < Trailblazer::Operation
    step :setup_query!
    step :apply_search!
    step :paginate!

    def setup_query!(ctx, **)
      
      ctx[:model] = ::Route.public_routes
                           .with_attached_images
                           .includes(:user, :city)
                           .recent
    end

    def apply_search!(ctx, params:, **)
      return true if params[:q].blank?

      query = "%#{params[:q]}%"
     
      ctx[:model] = ctx[:model].left_outer_joins(:city).where(
        'routes.name ILIKE :q OR routes.description ILIKE :q OR cities.name ILIKE :q',
        q: query
      ).distinct
    end

    def paginate!(ctx, params:, **)
      
      ctx[:model] = ctx[:model].page(params[:page]).per(12)
    end
  end
end