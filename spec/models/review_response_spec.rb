require 'rails_helper'

RSpec.describe ReviewResponse, type: :model do
  it 'has a valid factory' do
    expect(build(:review_response)).to be_valid
  end
end