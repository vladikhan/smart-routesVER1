FactoryBot.define do
  factory :entity_tag do
    association :tag
    association :entity, factory: :venue 
  end
end