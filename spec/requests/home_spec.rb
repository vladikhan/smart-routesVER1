require 'rails_helper'

RSpec.describe 'Home', type: :request do
  let!(:city) { create(:city) }
  let!(:user) { create(:user) }
  
  describe 'GET /' do
    let!(:trending_route) do
      create(:route, 
             user: user, 
             city: city, 
             is_featured: true,
             is_public: true,
             view_count: 100,
             created_at: 2.days.ago)
    end
    
    let!(:recent_route) do
      create(:route,
             user: user,
             city: city, 
             is_public: true,
             view_count: 10,
             created_at: 1.hour.ago)
    end
    
    it 'returns success' do
      get root_path
      expect(response).to have_http_status(:success)
    end
    
    it 'displays trending routes' do
      get root_path
      expect(response.body).to include(trending_route.name)
    end
    
    it 'displays recent routes' do
      recent_route = create(:route, name: "ルート 133", is_public: true, is_deleted: false)
      
      get root_path
      expect(response.body).to include(recent_route.name)
    end
  end
  
  describe 'GET /search' do
    let!(:route) do
      create(:route, 
             user: user,
             city: city,
             name: '京都文化ツアー',
             estimated_cost: 5000,
             is_public: true)
    end
    
    it 'searches by city name' do
      get search_path, params: { q: city.name }
      expect(response).to have_http_status(:success)
    end
    
    it 'searches by budget' do
      get search_path, params: { budget_min: 0, budget_max: 10000 }
      expect(response).to have_http_status(:success)
    end
    
    it 'returns JSON when requested' do
      get search_path, params: { q: city.name }, as: :json
      expect(response.content_type).to include('application/json')
    end
  end
end