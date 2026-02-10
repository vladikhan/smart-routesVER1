FactoryBot.define do
  factory :district do
    association :city

    # Используем sequence для уникальности
    sequence(:name) { |n| "地区 #{n}" }
    sequence(:name_en) { |n| "District #{n}" }
    
    # Добавляем описание (из твоего нового кода)
    description { "魅力的な地区です。" }
    
    # Полезный трейт, если в тестах нужно пустое описание
    trait :no_description do
      description { nil }
    end
  end
end