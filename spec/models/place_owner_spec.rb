require 'rails_helper'

RSpec.describe PlaceOwner, type: :model do
  it 'has a valid factory' do
    expect(build(:place_owner)).to be_valid
  end
end
