# spec/requests/follows_spec.rb
require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe 'POST /users/:user_id/follow' do
    let(:follow_params) { { user_id: other_user.id } }

    context 'with valid params' do
      it 'creates a new follower relationship' do
        expect {
          post user_follow_path(other_user), params: follow_params
        }.to change(Follower, :count).by(1)
      end

      it 'creates follower with correct attributes' do
        post user_follow_path(other_user), params: follow_params
        
        follower = Follower.last
        expect(follower.follower_id).to eq(user.id)
        expect(follower.following_id).to eq(other_user.id)
        expect(follower.status).to eq('pending')
      end

      it 'increments following_count for current user' do
        expect {
          post user_follow_path(other_user), params: follow_params
        }.to change { user.reload.following_count }.by(1)
      end

      it 'creates notification for followed user' do
        expect {
          post user_follow_path(other_user), params: follow_params
        }.to change(Notification, :count).by(1)
        
        notification = Notification.last
        expect(notification.user_id).to eq(other_user.id)
        expect(notification.actor_id).to eq(user.id)
        expect(notification.notification_type).to eq('follow_request')
      end

      context 'HTML format' do
        it 'redirects back to user profile' do
          post user_follow_path(other_user), params: follow_params
          expect(response).to redirect_to(user_path(other_user))
        end
      end

      context 'Turbo Stream format' do
        it 'returns turbo_stream response' do
          post user_follow_path(other_user), params: follow_params, as: :turbo_stream
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end

        it 'replaces follow button section' do
          post user_follow_path(other_user), params: follow_params, as: :turbo_stream
          expect(response.body).to include("follow_section_#{other_user.id}")
          expect(response.body).to include('turbo-stream')
          expect(response.body).to include('action="replace"')
        end

        it 'renders follow_button partial' do
          post user_follow_path(other_user), params: follow_params, as: :turbo_stream
          expect(assigns(:user)).to eq(other_user)
        end
      end
    end

    context 'when already following' do
      before do
        create(:follower, follower: user, following: other_user)
      end

      it 'does not create duplicate follower' do
        expect {
          post user_follow_path(other_user), params: follow_params
        }.not_to change(Follower, :count)
      end

      it 'redirects back with error' do
        post user_follow_path(other_user), params: follow_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('エラーが発生しました')
      end
    end

    context 'when trying to follow yourself' do
      it 'does not create follower' do
        expect {
          post user_follow_path(user), params: { user_id: user.id }
        }.not_to change(Follower, :count)
      end

      it 'redirects with error' do
        post user_follow_path(user), params: { user_id: user.id }
        expect(flash[:alert]).to eq('エラーが発生しました')
      end
    end

    context 'when user does not exist' do
      it 'raises RecordNotFound' do
        expect {
          post user_follow_path(id: 999999), params: { user_id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

   

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          post user_follow_path(other_user), params: follow_params
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'does not create follower' do
          expect {
            post user_follow_path(other_user), params: follow_params
          }.not_to change(Follower, :count)
        end
      end

      
    end

    context 'ActionCable broadcast' do
      it 'broadcasts notification to followed user' do
        expect {
          post user_follow_path(other_user), params: follow_params
        }.to have_broadcasted_to("notifications_#{other_user.id}")
      end
    end
  end

  describe 'DELETE /users/:user_id/unfollow' do
    let!(:follower_record) { create(:follower, follower: user, following: other_user) }
    let(:unfollow_params) { { user_id: other_user.id } }

    context 'when user is following' do
      it 'destroys the follower relationship' do
        expect {
          delete user_unfollow_path(other_user), params: unfollow_params
        }.to change(Follower, :count).by(-1)
      end

      it 'decrements following_count' do
        expect {
          delete user_unfollow_path(other_user), params: unfollow_params
        }.to change { user.reload.following_count }.by(-1)
      end

      context 'HTML format' do
        it 'redirects back to user profile' do
          delete user_unfollow_path(other_user), params: unfollow_params
          expect(response).to redirect_to(user_path(other_user))
        end
      end

      context 'Turbo Stream format' do
        it 'returns turbo_stream response' do
          delete user_unfollow_path(other_user), params: unfollow_params, as: :turbo_stream
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end

        it 'replaces follow button to "Follow" state' do
          delete user_unfollow_path(other_user), params: unfollow_params, as: :turbo_stream
          expect(response.body).to include("follow_section_#{other_user.id}")
          expect(assigns(:user)).to eq(other_user)
        end
      end
    end

    context 'when not following' do
      before { follower_record.destroy }

      it 'does not change follower count' do
        expect {
          delete user_unfollow_path(other_user), params: unfollow_params
        }.not_to change(Follower, :count)
      end

      it 'redirects with error' do
        delete user_unfollow_path(other_user), params: unfollow_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('ユーザーが見つからないか、解除に失敗しました')
      end
    end

    context 'authorization: when trying to unfollow someone else\'s relationship' do
      let(:stranger) { create(:user) }
      let!(:stranger_follow) { create(:follower, follower: stranger, following: other_user) }

      it 'does not destroy the stranger relationship' do
        expect {
          delete user_unfollow_path(other_user), params: { user_id: other_user.id }
        }.to change(Follower, :count).by(-1) # Удалит только связь текущего юзера
        
        expect(Follower.exists?(stranger_follow.id)).to be true
      end
    end
  end

  describe 'Integration: Follow -> Unfollow flow' do
    it 'creates follow, then removes it' do
      post user_follow_path(other_user), params: { user_id: other_user.id }
      expect(Follower.where(follower: user, following: other_user).exists?).to be true
      
      delete user_unfollow_path(other_user), params: { user_id: other_user.id }
      expect(Follower.where(follower: user, following: other_user).exists?).to be false
    end

    it 'correctly updates counters through full cycle' do
      original_count = user.following_count
      
      post user_follow_path(other_user), params: { user_id: other_user.id }
      expect(user.reload.following_count).to eq(original_count + 1)
      
      delete user_unfollow_path(other_user), params: { user_id: other_user.id }
      expect(user.reload.following_count).to eq(original_count)
    end
  end
end