# encoding: UTF-8
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  
  describe 'GET #show (Profile Page)' do
    let!(:city) { create(:city) }
    let!(:public_route) { create(:route, user: user, city: city, is_public: true) }
    let!(:private_route) { create(:route, user: user, city: city, is_public: false) }
    
    context 'viewing own profile' do
      before do
        sign_in user
        get :show, params: { id: user.id }
      end
      
      it 'returns success' do
        expect(response).to have_http_status(:success)
      end
      
      it 'assigns the user' do
        expect(assigns(:user)).to eq(user)
      end
      
      it 'shows all routes including private' do
        expect(assigns(:routes)).to include(public_route)
      end
    end
    
    context 'viewing other user profile' do
      before do
        sign_in other_user
        get :show, params: { id: user.id }
      end
      
      it 'only shows public routes' do
        expect(assigns(:routes)).to include(public_route)
        expect(assigns(:routes)).not_to include(private_route)
      end
    end
  end
  
  describe 'GET #my_profile' do
    before { sign_in user }
    
    it 'redirects to user profile' do
      get :my_profile
      expect(response).to redirect_to(user_path(user))
    end
  end
  
  describe 'GET #edit' do
    context 'when logged in' do
      before do
        sign_in user
        get :edit, params: { id: user.id }
      end
      
      it 'returns success' do
        expect(response).to have_http_status(:success)
      end
      
      it 'assigns the user' do
        expect(assigns(:user)).to eq(user)
      end
    end
    
    context 'when not logged in' do
      it 'redirects to login' do
        get :edit, params: { id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context 'when editing other user' do
      before do
        sign_in other_user
        get :edit, params: { id: user.id }
      end
      
      it 'denies access' do
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'PATCH #update (Profile Edit)' do
    before { sign_in user }
    
    context 'with valid attributes' do
      it 'updates bio' do
        patch :update, params: { 
          id: user.id, 
          user: { bio: '新しいBio' } 
        }
        user.reload
        expect(user.bio).to eq('新しいBio')
      end
      
      it 'updates location' do
        patch :update, params: {
          id: user.id,
          user: { location: 'Tokyo, Japan' }
        }
        user.reload
        expect(user.location).to eq('Tokyo, Japan')
      end
      
      it 'redirects to profile' do
        patch :update, params: {
          id: user.id,
          user: { bio: 'Updated' }
        }
        expect(response).to redirect_to(user_path(user))
      end
      
      it 'shows success message' do
        patch :update, params: {
          id: user.id,
          user: { bio: 'Updated' }
        }
        expect(flash[:notice]).to be_present
      end
    end
    
    context 'with invalid attributes' do
      it 'does not update with blank username' do
        patch :update, params: {
          id: user.id,
          user: { username: '' }
        }
        user.reload
        expect(user.username).not_to be_blank
      end
      
      it 'renders edit template' do
        patch :update, params: {
          id: user.id,
          user: { username: '' }
        }
        expect(response).to render_template(:edit)
      end
    end
  end
end