FactoryBot.define do
  factory :notification do
association :user
association :actor, factory: :user 

    user { nil }
    actor { nil }
    notification_type { %w[comment like follow review route_shared].sample }
    entity_type { 'Route' }
    entity_id { 1 }
    is_read { false }
    
    trait :read do
      is_read { true }
      read_at { Time.current }
    end
  end
end
