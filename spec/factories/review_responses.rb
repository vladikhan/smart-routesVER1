FactoryBot.define do
  factory :review_response do
    association :review
    association :user

    text { "貴重なご意見ありがとうございます。対応いたします。" }
  end
end
