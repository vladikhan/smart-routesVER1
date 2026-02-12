require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:text) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:reviewable) }
    it { should have_many(:review_images) }
  end
end
