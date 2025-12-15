FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    
    # ВАЖНО: Вместо confirmed_at используем email_verified!
    email_verified { true }
    confirmed_at { Time.current }
    
    # Опциональные поля
    bio { 'Test user bio' }
    location { 'Tokyo' }
    
    trait :unverified do
      email_verified { false }
    end
    
    trait :admin do
      is_admin { true }
    end
    
    trait :banned do
      is_banned { true }
      banned_at { Time.current }
    end
  end
end
