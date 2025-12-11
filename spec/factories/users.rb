FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    bio { Faker::Lorem.sentence }
    location { Faker::Address.city }
    budget_min { 1000 }
    budget_max { 10000 }
    email_verified { true }
    
    before(:create) do |user|
      user.skip_confirmation_notification!
    end

    trait :admin do
      is_admin { true }
    end

    trait :confirmed do
      after(:create) do |user|
        user.confirm # Подтверждаем пользователя вручную без отправки письма
      end
    end
    
    trait :with_avatar do
      
    end
  end
end