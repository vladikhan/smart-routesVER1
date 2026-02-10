FactoryBot.define do
  factory :route_item do
    association :route
    association :venue

    sequence(:position) { |n| n }
    
    item_type { 'venue' }
    duration_minutes { 60 }
    notes { "訪問メモ" }

    venue_name { venue.name }
    venue_address { venue.address }

    # Если вдруг venue нет (например, кастомная точка), используем Faker как запасной вариант
    # venue_name { venue&.name || Faker::Restaurant.name }
  end
end

