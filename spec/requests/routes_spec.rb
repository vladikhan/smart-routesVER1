require 'rails_helper'

RSpec.describe 'Routes API', type: :request do
  let(:user) { create(:user) }
  let(:city) { create(:city) }
  let!(:route) { create(:route, user: user, city: city) }
  
  describe 'GET /routes' do
    let!(:public_route) { create(:route, is_public: true, city: city, user: user) }
    let!(:private_route) { create(:route, is_public: false, city: city, user: user) }
    
    it 'shows public routes' do
      get routes_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(public_route.name)
    end
    
    it 'does not show private routes' do
      get routes_path
      expect(response.body).not_to include(private_route.name)
    end
  end
  
  describe 'GET /routes/:id' do
    it 'shows route details' do
      get route_path(route)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(route.name)
    end
    
    it 'increments view count' do
      expect {
        get route_path(route)
      }.to change { route.reload.view_count }.by(1)
    end
  end
  
  describe 'GET /routes/new' do
    context 'when authenticated' do
      before { sign_in user }
      
      it 'shows new form' do
        get new_route_path
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to login' do
        get new_route_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'POST /routes' do
    let(:valid_params) do
      {
        route: {
          name: 'Test Route',
          description: 'Description',
          city_id: city.id,
          estimated_duration: 300,
          estimated_cost: 5000,
          is_public: true
        }
      }
    end
    
    context 'when authenticated' do
      before { sign_in user }
      
      it 'creates route' do
        expect {
          post routes_path, params: valid_params
        }.to change(Route, :count).by(1)
      end
      
      it 'redirects to route' do
        post routes_path, params: valid_params
        expect(response).to redirect_to(Route.last)
      end
      
      it 'shows success message' do
        post routes_path, params: valid_params
        follow_redirect!
        expect(response.body).to include('作成')
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to login' do
        post routes_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'GET /routes/:id/edit' do
    context 'when owner' do
      before { sign_in user }
      
      it 'shows edit form' do
        get edit_route_path(route)
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when other user' do
      let(:other_user) { create(:user) }
      before { sign_in other_user }
      
      it 'denies access' do
        get edit_route_path(route)
        expect(response).to redirect_to(routes_path)
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to login' do
        get edit_route_path(route)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'PATCH /routes/:id' do
    context 'when owner' do
      before { sign_in user }
      
      it 'updates route' do
        patch route_path(route), params: {
          route: { name: 'Updated Name' }
        }
        expect(route.reload.name).to eq('Updated Name')
      end
      
      it 'redirects to route' do
        patch route_path(route), params: {
          route: { name: 'Updated' }
        }
        expect(response).to redirect_to(route)
      end
    end
    
    context 'when other user' do
      let(:other_user) { create(:user) }
      before { sign_in other_user }
      
      it 'denies access' do
        patch route_path(route), params: {
          route: { name: 'Hacked' }
        }
        expect(response).to redirect_to(routes_path)
        expect(route.reload.name).not_to eq('Hacked')
      end
    end
  end
  
  describe 'DELETE /routes/:id' do
    context 'when owner' do
      before { sign_in user }
      
      it 'deletes route' do
        route_to_delete = create(:route, user: user, city: city)
        expect {
          delete route_path(route_to_delete)
        }.to change(Route, :count).by(-1)
      end
      
      it 'redirects to routes index' do
        delete route_path(route)
        expect(response).to redirect_to(routes_path)
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to login' do
        delete route_path(route)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end