class PagesController < ApplicationController
  def home
    @routes_count = Route.count rescue 0
    @venues_count = Venue.count rescue 0
    @users_count = User.count rescue 0
    @reviews_count = Review.count rescue 0
  
    #人気ルート
    @featured_routes = Rails.cache.fetch("featured_routes", expires_in: 1.hour) do
    Route.where(is_featured: true).order(:featured_order).limit(6).to_a
    end
    
    #where(is_public: true).order(view_count: :desc).limit(6) rescue []

    #人気レストラン（人気スポット）
    @popular_venues = Rails.cache.fetch("popular_venues", expires_in: 1.hour) do
    Venue.order(average_rating: :desc).limit(6).to_a
    end
  end
    
  def logout_confirm
    
  end
end
