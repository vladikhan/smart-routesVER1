require 'rails_helper'

RSpec.describe RouteItem, type: :model do
  describe 'coordinates' do 
    it 'is invalid with latitude greater than 90' do
      item = build(:route_item, geo_lat: 95.0)
      expect(item).to_not be_valid
    end

    it 'is invalid with longitude greater that 180' do 
      item = build(:route_item, geo_lng: 200.0)
      expect(item).not_to be_valid
    end
  end
end
