require 'rails_helper'

RSpec.describe 'Routes API', type: :request do
  let(:user) { create(:user) }
  let(:city) { create(:city, :with_districts) }
  
  describe 'GET /routes' do
    let!(:routes) { create_list(:route, 10, is_public: true, city: city) }
    
    it 'ルート一覧を返す' do
      get routes_path
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'POST /routes' do
    before { sign_in user }
    
    let(:valid_params) do
      {
        route: {
          name: 'テストルート',
          description: '説明',
          city_id: city.id,
          is_public: true
        }
      }
    end
    
    it 'ルートを作成する' do
      expect {
        post routes_path, params: valid_params
      }.to change(Route, :count).by(1)
      
      expect(response).to have_http_status(:redirect)
    end
  end
end