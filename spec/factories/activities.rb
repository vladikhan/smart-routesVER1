FactoryBot.define do
  factory :activity do
    association :user
    association :trackable, factory: :route
    key { "review.create" }
  end
end
