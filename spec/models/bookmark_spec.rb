require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it 'prevents duplicate bookmark for the same user and route' do
    user = create(:user)
    route = create(:route)
    create(:bookmark, user: user, route: route)

    duplicate = build(:bookmark, user: user, route: route)
    expect(duplicate).to_not be_valid
  end
end
