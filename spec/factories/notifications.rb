FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user

    notification_type { 'follow_request' }
    is_read { false }
    message { nil }

    trait :read do 
      is_read { true }
      read_at { Time.current }
    end

    trait :new_message do
      notification_type { 'new_message' }
      association :notifiable, factory: dm_message
      message { '#{actor.username}さんから新しいメッセージが届きました'}
    end

    trait :route_liked do
      notification_type { 'route_liked' }
      association :notifiable, factory: :route
      message { '#{actor.username}さんがあなたのルートにいいねしました' }
    end
  end
end