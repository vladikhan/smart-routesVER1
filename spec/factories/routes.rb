# Encoding: UTF-8
FactoryBot.define do
  factory :route do
    association :user
    association :city
    sequence(:name) { |n| "ルート #{n}" }
    description { Faker::Lorem.paragraph }
    estimated_duration { rand(60..480) }
    estimated_cost { rand(1000..10000) }
    difficulty_level { %w[easy medium hard].sample }
    is_public { true }
    view_count { 0 }
    likes_count { 0 }
    bookmarks_count { 0 }
    
    trait :private do
      is_public { false }
    end
    
    trait :with_items do
      after(:create) do |route|
        create_list(:route_item, 3, route: route)
      end
    end
  end
end