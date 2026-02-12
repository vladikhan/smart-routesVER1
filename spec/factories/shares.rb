FactoryBot.define do
  factory :share do
    association :user
    association :route
  end
end
