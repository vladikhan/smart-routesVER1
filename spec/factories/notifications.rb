FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    notification_type { 'like' }
    entity_type { 'Route' }
    entity_id { 1 }
    is_read { false }
    
    trait :read do
      is_read { true }
    end
    
    trait :unread do
      is_read { false }
    end
  end
end
