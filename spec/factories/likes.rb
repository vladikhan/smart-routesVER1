FactoryBot.define do
  factory :like do
    association :user

    association :likeable, factory: :route

    trait :for_venue do
      association :likeable, factory: :venue
    end

    trait :for_review do
      association :likeable, factory: :review
    end
  end
end
