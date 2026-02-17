module Page::Operation
  class Home < Trailblazer::Operation
    step :fetch_stats!
    step :fetch_featured_content!

    def fetch_stats!(ctx, **)
      ctx[:stats] = {
        total_routes:  Route.count,  
        total_venues:  Venue.count,   
        total_users:   User.count,    
        total_reviews: Review.count
      }
    end

    def fetch_featured_content!(ctx, **)
      ctx[:featured_routes] = Route.where(is_public: true, is_deleted: false, is_featured: true)
                                   .order(featured_order: :asc)
                                   .limit(6)
      ctx[:popular_venues]  = Venue.order(average_rating: :desc)
                                   .limit(6)
      ctx[:recent_routes]   = Route.where(is_public: true, is_deleted: false)
                                   .order(created_at: :desc).limit(6)
    end
  end
end