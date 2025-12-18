class HomeController < ApplicationController
  def index
    @trending_routes = Route.where(is_public: true)
                            .where('created_at > ?', 30.days.ago)
                            .order(view_count: :desc)
                            .limit(6)
                            .to_a
    
    @recent_routes = Route.where(is_public: true)
                          .order(created_at: :desc)
                          .limit(6)
                          .to_a
    
    if params[:q].present?
      @search_results = Route.where(is_public: true)
                             .where('name LIKE ? OR description LIKE ?', 
                                    "%#{params[:q]}%", "%#{params[:q]}%")
    end
  end

  def search
    @routes = Route.where(is_public: true)
    
    if params[:q].present?
      @routes = @routes.where('name LIKE ? OR description LIKE ?',
                              "%#{params[:q]}%", "%#{params[:q]}%")
    end
    
    if params[:city].present?
      @routes = @routes.joins(:city).where(cities: { name: params[:city] })
    end
    
    if params[:budget_min].present? || params[:budget_max].present?
      min_budget = params[:budget_min].to_i
      max_budget = params[:budget_max].to_i
      
      if min_budget > 0 && max_budget > 0
        @routes = @routes.where('estimated_cost >= ? AND estimated_cost <= ?', 
                               min_budget, max_budget)
      elsif min_budget > 0
        @routes = @routes.where('estimated_cost >= ?', min_budget)
      elsif max_budget > 0
        @routes = @routes.where('estimated_cost <= ?', max_budget)
      end
    end
    
    @routes = @routes.limit(20)
    
    respond_to do |format|
      format.html
      format.json { render json: @routes }
    end
  end
end
