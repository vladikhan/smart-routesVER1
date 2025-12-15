FactoryBot.define do
  factory :district do
    association :city
    sequence(:name) { |n| "District#{n}" }
    name_en { name }
  end
end
