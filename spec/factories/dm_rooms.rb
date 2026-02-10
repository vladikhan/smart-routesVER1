FactoryBot.define do
  factory :dm_room do
    association :sender, factory: :user
    association :receiver, factory: :user
    
    last_message_at { nil }
    unread_count_sender { 0 }
    unread_count_receiver { 0 }
    
    trait :with_messages do
      after(:create) do |room|
        create_list(:dm_message, 3, dm_room: room, user: room.sender)
        room.update(last_message_at: Time.current)
      end
    end
    
    trait :with_unread do
      unread_count_receiver { 5 }
    end
  end
end