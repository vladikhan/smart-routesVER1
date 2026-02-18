require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'has a valid factory' do
    user = create(:user)
    comment = build(:comment, user: user)
    expect(comment).to be_valid
  end
end