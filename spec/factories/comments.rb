FactoryBot.define do
  factory :comment do
    text { "いいコメントですね！"}
    association :user
    association :commentable, factory: :venue
  end
end
