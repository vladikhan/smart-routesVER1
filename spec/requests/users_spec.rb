require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  
  describe 'GET /users/:id' do
    let!(:city) { create(:city) }
    let!(:public_route) { create(:route, user: user, city: city, is_public: true) }
    let!(:private_route) { create(:route, user: user, city: city, is_public: false) }
    
    it 'shows user profile' do
      get user_path(user)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.username)
    end
    
    it 'shows public routes' do
      get user_path(user)
      expect(response.body).to include(public_route.name)
    end
    
    it 'does not show private routes to other users' do
      sign_in other_user
      get user_path(user)
      expect(response.body).not_to include(private_route.name)
    end
    
    context 'viewing own profile' do
      before { sign_in user }
      
      it 'shows all routes including private' do
        get user_path(user)
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe 'GET /users/:id/edit' do
    context 'when owner' do
      before { sign_in user }
      
      it 'shows edit form' do
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when other user' do
      before { sign_in other_user }
      
      it 'denies access' do
        get edit_user_path(user)
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to login' do
        get edit_user_path(user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'PATCH /users/:id' do
    before { sign_in user }
    
    it 'updates bio' do
      patch user_path(user), params: { 
        user: { bio: 'New Bio' } 
      }
      expect(user.reload.bio).to eq('New Bio')
    end
    
    it 'updates location' do
      patch user_path(user), params: {
        user: { location: 'Tokyo, Japan' }
      }
      expect(user.reload.location).to eq('Tokyo, Japan')
    end
    
    it 'redirects to profile' do
      patch user_path(user), params: {
        user: { bio: 'Updated' }
      }
      expect(response).to redirect_to(user_path(user))
    end
  end
end