class PagesController < ApplicationController
  def home
    @routes_count = begin
      Route.count
    rescue StandardError
      0
    end
    @venues_count = begin
      Venue.count
    rescue StandardError
      0
    end
    @users_count = begin
      User.count
    rescue StandardError
      0
    end
    @reviews_count = begin
      Review.count
    rescue StandardError
      0
    end

    # 人気ルート
    @featured_routes = Route.where(is_public: true).order(view_count: :desc).limit(6).to_a
    # 人気レストラン（人気スポット）
    @popular_venues = Venue.order(average_rating: :desc).limit(6).to_a

    @recent_routes = Route.where(is_public: true).order(created_at: :desc).limit(6)
  end
end

# app/models/review.rb
def update_reviewable_rating
  all_reviews = reviewable.reviews

  return unless all_reviews.any?

  avg_rating = all_reviews.average(:total_score).to_f.round(1)
  reviewable.update_columns(
    average_rating: avg_rating,
    reviews_count: all_reviews.count
  )
end

def logout_confirm
end
