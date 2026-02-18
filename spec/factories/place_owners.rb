FactoryBot.define do
  factory :place_owner do
    association :user
    association :venue

    role { :owner }
  end
end
