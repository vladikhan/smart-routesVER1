FactoryBot.define do
  factory :review_image do
    association :review
    position { 1 }

    image do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/files/test_image.jpg'), 
        'image/jpeg'
      )
    end
  end
end