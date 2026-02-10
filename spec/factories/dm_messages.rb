FactoryBot.define do
  factory :dm_message do
    association :dm_room
    association :user
    
    message { "テストメッセージ #{Faker::Lorem.sentence(word_count: 3)}" }
    is_read { false }
    
    trait :read do
      is_read { true }
      read_at { Time.current }
    end
    
    trait :with_emoji do
      message { "こんにちは！ 😊🎉✨" }
    end
    
    trait :long_message do
      message { Faker::Lorem.paragraph(sentence_count: 5) }
    end
  end
end