require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /users' do
    it 'returns success' do
      get users_path
      expect(response).to have_http_status(:success)
    end

    it 'lists users' do
      get users_path
      expect(response.body).to include(user.username)
    end
  end

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

    context 'when user does not exist' do
      it 'redirects to users index with alert' do
        get user_path(id: 999999)
        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to be_present
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
      it 'denies access and redirects to root' do
        sign_in other_user
        get edit_user_path(user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('アクセス権限がありません')
      end
    end

    context 'when admin' do
      it 'allows access' do
        admin = create(:user, :admin)
        sign_in admin
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
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
    context 'when owner' do
      before { sign_in user }

      it 'updates bio' do
        patch user_path(user), params: { user: { bio: 'New Bio' } }
        expect(user.reload.bio).to eq('New Bio')
      end

      it 'updates location' do
        patch user_path(user), params: { user: { location: 'Tokyo, Japan' } }
        expect(user.reload.location).to eq('Tokyo, Japan')
      end

      it 'redirects to profile with notice' do
        patch user_path(user), params: { user: { bio: 'Updated' } }
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq('プロフィールを更新しました')
      end
    end

    context 'when other user' do
      before { sign_in other_user }

      it 'denies update' do
        patch user_path(user), params: { user: { bio: 'Hacked' } }
        expect(response).to redirect_to(root_path)
        expect(user.reload.bio).not_to eq('Hacked')
      end
    end
  end

  describe 'GET /users/:id/comments' do
    it 'requires authentication' do
      get comments_user_path(user)
      expect(response).to redirect_to(new_user_session_path)
    end

    context 'when authenticated' do
      before { sign_in user }

      it 'returns success' do
        get comments_user_path(other_user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET my_profile' do
    it 'redirects to login when not signed in' do
      get my_profile_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to current user profile when signed in' do
      sign_in user
      get my_profile_path
      expect(response).to redirect_to(user_path(user))
    end
  end

  describe 'POST /users/:id/follow' do
    it 'requires authentication' do
      post follow_user_path(other_user)
      expect(response).to redirect_to(new_user_session_path)
    end

    context 'when authenticated' do
      before { sign_in user }

      it 'follows user and redirects back with notice' do
        post follow_user_path(other_user)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq('フォローしました')
        expect(user.following?(other_user)).to be true
      end
    end
  end

  describe 'DELETE /users/:id/unfollow' do
    before { user.follow(other_user) }

    it 'requires authentication' do
      delete unfollow_user_path(other_user)
      expect(response).to redirect_to(new_user_session_path)
    end

    context 'when authenticated' do
      before { sign_in user }

      it 'unfollows and redirects back with notice' do
        delete unfollow_user_path(other_user)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq('フォロー解除済み')
        expect(user.following?(other_user)).to be false
      end
    end
  end
end