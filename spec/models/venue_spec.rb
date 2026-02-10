require 'rails_helper'

RSpec.describe Venue, type: :model do
  it 'is invalid without latitude and longitude' do
    venue = build(:venue, latitude: nil, longitude: nil)
    expect(venue).to_not be_valid
  end
end
z