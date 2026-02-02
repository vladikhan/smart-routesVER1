module Page::Operation
  class Home < Trailblazer::Operation
    step :fetch_stats!
    step :fetch_featured_content!

    def fetch_stats!(ctx, **)
      ctx[:stats] = {
        routes:  Route.count,
        venues:  Venue.count,
        users:   User.count,
        reviews: Review.count
      }
    end

    def fetch_featured_content!(ctx, **)
      ctx[:featured_routes] = Route.where(is_public: true).order(view_count: :desc).limit(6)
      ctx[:popular_venues]  = Venue.order(average_rating: :desc).limit(6)
      ctx[:recent_routes]   = Route.where(is_public: true).order(created_at: :desc).limit(6)
    end
  end
end