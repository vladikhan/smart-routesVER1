FactoryBot.define do
  factory :venue do
    association :district

    name { Faker::Restaurant.name }
    venue_type { %w[restaurant cafe attraction museum].sample }
    address { Faker::Address.full_address }
    description { Faker::Lorem.paragraph }
    price_range { "MyString" }
    geo_lat { Faker::Address.latitude }
    geo_lng { Fakse::Address.longitude }
    
    status { 'approved' }
    
    trait :pending do
      status { 'pending'}
    end
  end
end
