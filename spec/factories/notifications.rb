# spec/factories/notifications.rb
FactoryBot.define do
  factory :notification do
    user
    actor { association :user }
    notification_type { 'like' }
    
    # Используй entity_type и entity_id:
    entity_type { 'Route' }
    entity_id { create(:route).id }
    
    is_read { false }
    
    trait :unread do
      is_read { false }
    end
    
    trait :read do
      is_read { true }
    end
  end
end