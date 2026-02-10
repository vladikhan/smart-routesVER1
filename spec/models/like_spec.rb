require 'rails_helper'

RSpec.describe Like, type: :model do
  it 'is invalid if a user likes the same venue twice' do
    user = create(:user)
    venue = create(:venue)
    create(:like, user: user, venue: venue)

    duplicate = build(:like, user: user, venue: venue)
    expect(duplicate).not_to be_valid
  end
end
