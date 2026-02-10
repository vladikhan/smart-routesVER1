FactoryBot.define do
  factory :review do
    association :user
    association :reviewable, factory: :venue
    
    text { "とても素晴らしい場所でした。また行きたいです。" }
    is_flagged { false }
    is_hidden_by_admin { false }
    likes_count { 0 }
    
    trait :excellent do
      text { "完璧な体験でした！絶対におすすめします！" }
    end
    
    trait :poor do
      text { "期待外れでした。改善が必要です。" }
    end
    
    trait :flagged do
      is_flagged { true }
      flagged_at { Time.current }
    end
    
    trait :hidden do
      is_hidden_by_admin { true }
    end
  end
end
