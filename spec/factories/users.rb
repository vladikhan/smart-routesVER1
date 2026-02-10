FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    
    bio { "こんにちは！テストユーザーです。" }
    location { "東京" }
    is_admin { false }
    is_banned { false }
    email_verified { true }
    is_online { false }
    langauge { "ja" }
    timezone { "Asia/Tokyo" }
    
    trait :admin do
      is_admin { true }
    end
    
    trait :online do
      is_online { true }
      last_seen_at { Time.current }
    end
    
    trait :with_avatar do
      image_url { "https://i.pravatar.cc/300?img=#{rand(1..70)}" }
    end
    
    trait :banned do
      is_banned { true }
      banned_at { Time.current }
      ban_reason { "利用規約違反" }
    end
  end
end