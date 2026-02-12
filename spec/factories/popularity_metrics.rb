FactoryBot.define do
  factory :popularity_metric do
    association :entity, factory: :route
    view_count { 1 }
    like_count { 1 }
    save_count { 1 }
    comment_count { 1 }
    share_count { 1 }
    download_count { 1 }
    completion_count { 1 }
    popularity_score { 1.5 }
    trending_score { 1.5 }
    daily_views { 1 }
    weekly_views { 1 }
    monthly_views { 1 }
    last_calculated_at { "2025-10-24 11:57:10" }
  end
end
