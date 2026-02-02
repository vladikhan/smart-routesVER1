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
      @search_results = Route::Operation::Search.call(params: params)[:model]
    end
  end

  def search
    result = Route::Operation::Search.call(params: params)
    @routes = result[:model]
    
    respond_to do |format|
      format.html
      format.json { render json: @routes}
    end
  end
end
