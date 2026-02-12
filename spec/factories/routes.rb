# Encoding: UTF-8
FactoryBot.define do
  factory :route do
    association :user
    association :city


    sequence(:name) { |n| "ルート #{n}" }
    description { 
      Faker::Config.locale = 'ja'
      Faker::Address.city + " を巡る素晴らしいルートです。" 
    }

    #Number data
    estimated_duration { rand(60..480) }
    estimated_cost { rand(1000..10000) }
    difficulty_level { %w[easy medium hard].sample }

    #Counters
    is_public { true }
    is_deleted { false }
    is_featured { false }
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

    trait :weekend_trip do
      estimated_duration { 360 }
      difficulty_level { 'medium' }
    end
  end
end