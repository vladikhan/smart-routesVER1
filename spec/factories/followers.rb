FactoryBot.define do
  factory :follower do
    follower_id { create(:user).id }
    following_id { create(:user).id }
    
    status { "pending" }
    
    # trait :accepted do
    #   status { "accepted" }
    # end
    
    # trait :rejected do
    #   status { "rejected" }
    # end
  end
end