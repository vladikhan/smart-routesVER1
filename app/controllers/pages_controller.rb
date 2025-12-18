class PagesController < ApplicationController
  def home
    @routes_count = Route.count rescue 0
    @venues_count = Venue.count rescue 0
    @users_count = User.count rescue 0
    @reviews_count = Review.count rescue 0
  
    #人気ルート
    @featured_routes = Route.where(is_public: true).order(view_count: :desc).limit(6).to_a
    #人気レストラン（人気スポット）
    @popular_venues = Venue.order(average_rating: :desc).limit(6).to_a
    
    @recent_routes = Route.where(is_public: true).order(created_at: :desc).limit(6)
  end
    
end


    # app/models/review.rb
def update_reviewable_rating
  all_reviews = reviewable.reviews
  
  if all_reviews.any?
    avg_rating = all_reviews.average(:total_score).to_f.round(1)
    reviewable.update_columns(
      average_rating: avg_rating,
      reviews_count: all_reviews.count
    )
  end
end

    def logout_confirm
    
    end
