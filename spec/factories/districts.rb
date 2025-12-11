FactoryBot.define do
  factory :district do
    association :city
    name { Faker::Address.community }
  end
end