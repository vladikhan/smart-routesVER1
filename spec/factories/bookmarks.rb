FactoryBot.define do
  factory :bookmark do
    association :user
    association :item, factory: :route

    collection_name { nil }
    notes { nil }

    trait :with_venue do
      association :item, factory: :venue
    end

    # trait :with_notes do
    #   notes { "後で訪問したい！" }
    # end

    # trait :in_collection do
    #   collection_name { "お気に入り" }
    # end
  end
end
