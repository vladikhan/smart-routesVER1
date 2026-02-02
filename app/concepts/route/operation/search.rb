module Route::Operation
  class Search < Trailblazer::Operation
    step :base_query!
    step :filter_by_query!
    step :filter_by_city!
    step :filter_by_budget!
    step :paginate!

    def base_query!(ctx, **)
      ctx[:model] = Route.where(is_public: true).with_attached_images.includes(:city)
    end

    def filter_by_query!(ctx, params:, **)
      return true if params[:q].blank?
      query = "%#{params[:q]}%"
      ctx[:model] = ctx[:model].where('name LIKE ? OR description LIKE ?', query, query)
    end

    def filter_by_city!(ctx, params:, **)
      return true if params[:city].blank?
      ctx[:model] = ctx[:model].joins(:city).where(cities: { name: params[:city] })
    end

    def filter_by_budget!(ctx, params:, **)
      min = params[:budget_min].to_i
      max = params[:budget_max].to_i

      ctx[:model] = ctx[:model].where('estimated_cost >= ?', min) if min > 0
      ctx[:model] = ctx[:model].where('estimated_cost <= ?', max) if max > 0
      true
    end

    def paginate!(ctx, **)
      ctx[:model] = ctx[:model].limit(20)
    end
  end
end