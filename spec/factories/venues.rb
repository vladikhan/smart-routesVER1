FactoryBot.define do
  factory :venue do
    # 1. Ассоциации
    association :district
    association :user

    # 2. Базовые поля (используем Faker для разнообразия)
    sequence(:name) { |n| "#{Faker::Restaurant.name} #{n}" }
    venue_type { %w[restaurant cafe attraction museum].sample }
    address { Faker::Address.full_address }
    description { Faker::Lorem.paragraph }
    
    geo_lat { Faker::Address.latitude }
    geo_lng { Faker::Address.longitude }
    
    # 3. Значения по умолчанию
    status { 'approved' }
    is_featured { false }
    view_count { 0 }
    average_rating { 0.0 }
    price_range { '¥¥' }

    # 4. Трейты (Твоя суперсила в тестах)
    
    trait :pending do
      status { 'pending' }
    end

    trait :restaurant do
      venue_type { 'restaurant' }
      cuisine_type { 'japanese' }
      price_range { '¥¥' }
    end

    trait :cafe do
      venue_type { 'cafe' }
      price_range { '¥' }
    end

    trait :featured do
      is_featured { true }
      featured_order { 1 }
    end

    trait :claimed do
      is_claimed { true }
      claimed_at { Time.current }
      verified_business { true }
    end
  end
end