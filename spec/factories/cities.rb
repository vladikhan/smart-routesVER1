FactoryBot.define do
  factory :city do
    name { Faker::Address.city }
    name_en { Faker::Address.city }
    
    trait :with_districts do
      after(:create) do |city|
        create_list(:district, 3, city: city)
      end
    end
  end
end