class HomeController < ApplicationController
  def index
    #Search params
    @query = params[:query]
    @city = params[:city]
    @tags = params[:tags]&.split(',')&.map(&:strip)
    @budget = params[:budget]

    #Searching and getting new routes
    if search_params_present?
      @routes = search_routes
      @search_active = true
    else
      @routes = fetch_new_routes
      @search_active = true
    else
      @routes = fetch_new_routes
      @search_active = false
    end

    #Cache statistics
    @stats = fetch_stats
  end

  #Searching routes(AJAX)
  def search
    @query = params[:query]
    @city = params[:city]
    @tags = params[:tags]&.split(',')&.map(&:strip)
    @budget = params[:budget]

    @routes = search_routes

    respond_to do |format|
      format.html { render partial: 'routes_list', locals: { routes: @routes } }
      formal.json { render json: @routes }
    end
  end

  private

  #Checking for existing search params

  def search_params_present?
    @query.present? || @city.present? || @tags.present? || @budget.present?
  end

  #Searching routes with filters
  def search_routes
    cache_key = "search:#{cache_key_from_params}"

    Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      routes = Route.where(is_public: true).includes(:user, :city)

      #Searchingby name/description
      if @query.present?
        routes = routes.where(
          "name ILIKE ? OR description ILIKE ?",
          "%#{@query}%",
          "%#{@query}%"
        )
      end

      #Filter by city
      if @city.present?
        routes = routes.joins(:city).where(cities: { name: @city})
      end

      #Filter by tags 
      if @tags.present?
        @tags.each do |tag|
          routes = routes.where("tags ILIKE ?","%#{tag}%")
        end
      end

      #Filter by budget
      if @budget.present?
        budget_range = budget_range_for(@budget)
        routes = routes.where(estimated_cost: budget_range) if budget_range
      end

      routes.order(created_at: :desc).limit(20).to_a
    end
  end

  #Getting new routes(with cache)
  def fetch_new_routes
    Rails.cache.fetch('home:new_routes', expires_in: 10.minutes) do 
      Route.where(is_public: true)
      .includes(:user, :city)
      .order(created_at: :desc)
      .limit(12)
      .to_a
    end
  end

  #Getting stats (with cache)
  def fetch_stats
    Rails.cache.fetch('home:stats', expires_in: 1.hour) do
      {
        routes_count: Route.where(is_public: true).count,
        venues_count: Venues.count,
        users_count: User.where.not(confirmed_at: nil).count,
        reviews_count: Review.count
      }
    end
  end

  #Budget Range
  def budget_range_for(budget_type)
    case budget_type
    when 'low'
      0..5000
    when 'medium'
      5000..15000
    when 'high'
      15000..Float::INFINITY
    else
      nil
    end
  end

  #Cache key from params
  def cache_key_from_params
    [
      @query.presence || 'no_query',
      @city.presence || 'no_city'
      @tags&.join('_') || 'no_tags'
      @budget.presence || 'no_budget'
  ].join(':')
  end
end
