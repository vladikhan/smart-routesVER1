FactoryBot.define do
  factory :route_item do
    association :route
    association :venue
    
    position { 1 }
    duration_minutes { 60 }
    venue_name { Faker::Restaurant.name }
    venue_address { Faker::Address.full_address }
    item_type { 'venue' }
  end
end