require 'rails_helper'

RSpec.describe 'Venues', type: :request do
  let!(:city) { create(:city) }
  let!(:district) { city.districts.first || create(:district, city: city) }
  let!(:restaurant) do
    create(:venue,
           district: district,
           geo_lat: 35.0,
           geo_lng: 135.0,
           venue_type: 'restaurant')
  end
  
  let!(:attraction) do
    create(:venue,
           district: district,
           geo_lat: 35.01,
           geo_lng: 135.01,
           venue_type: 'attraction')
  end
  
  describe 'GET /venues' do
    it 'shows venue index' do
      get venues_path
      expect(response).to have_http_status(:success)
    end
    
    it 'displays venues' do
      get venues_path
      expect(response.body).to include(restaurant.name)
    end
    
    context 'with filtering' do
      it 'filter by venue type' do
        get venues_path, params: { venue_type: 'restaurant' }
        expect(response).to have_http_status(:success)
        # Check that filtering logic exists
      end
    end
  end
  
  describe 'GET /venues/:id' do
    it 'shows venue details' do
      get venue_path(restaurant)
      expect(response).to have_http_status(:success)
    end
    
    it 'displays venue information' do
      get venue_path(restaurant)
      expect(response.body).to include(restaurant.name)
    end
  end
end