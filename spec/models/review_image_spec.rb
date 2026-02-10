require 'rails_helper'

RSpec.describe ReviewImage, type: :model do
  it 'has a valid factory' do
    expect(build(:review_image)).to be_valid
  end
end