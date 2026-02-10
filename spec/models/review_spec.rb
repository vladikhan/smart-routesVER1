require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:comment) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:route) }
  end
end
