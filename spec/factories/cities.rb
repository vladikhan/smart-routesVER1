FactoryBot.define do
  next if FactoryBot.factories.registered?(:city)
  
  factory :city do
    sequence(:name) { |n| "City#{n}" }
    sequence(:name_en) { |n| "City#{n}" }
    description { "City description" }
    
    trait :with_districts do
      after(:create) do |city|
        create_list(:district, 3, city: city)
      end
    end
  end
end
