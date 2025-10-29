class PagesController < ApplicationController
  def home
    @routes_count = Route.count rescue 0
    @venues_count = Venue.count rescue 0
    @users_count = User.count rescue 0
    @reviews_count = Review.count rescue 0
    
    @featured_routes = Route.where(is_public: true).order(view_count: :desc).limit(6) rescue []
  end
end
