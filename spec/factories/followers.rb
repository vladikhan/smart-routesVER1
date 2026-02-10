FactoryBot.define do
  factory :follower do
    association :follower, factory: :user
    association :following, factory: :user
    
    status { "pending" }
    
    trait :accepted do
      status { "accepted" }
    end
    
    trait :rejected do
      status { "rejected" }
    end
  end
end