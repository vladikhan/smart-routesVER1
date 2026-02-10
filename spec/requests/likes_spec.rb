require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  let(:user) { create(:user) }
  let(:route) { create(:route) }
  let(:venue) { create(:venue) }
  let(:review) { create(:review) }

  before { sign_in user }

  describe 'POST /likes' do
    context 'liking a route' do
      let(:route_params) do
        {
          likeable_id: route.id,
          likeable_type: 'Route'
        }
      end

      it 'creates a new like' do
        expect {
          post likes_path, params: route_params
      }.to change(Like, :count).by(1)
      end

      it 'creates like with correct attrributes' do
        post likes_path, params: route_params

        like = Like.last
        expect(like.user_id).to eq(user.id)
        expect(like.likeable_type).to eq('Route')
        expect(like.likeable_id).to eq(route.id)
      end

      it 'redirects back with success notice' do
        post likes_path, params: route_params

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('いいねしました!')
      end

      it 'creates notification for route owner' do
        owner = route.user

        expect {
          post likes_path, params: route_params
        }.to change { owner.notifications.count }.by(1)

        notification = owner.notifications.last
        expect(notification.notifiable_type).to eq('route_liked')
        expect(notification.actor_id).to eq(user.id)
      end
    end

    context 'liking a venue' do
      let(:venue_params) do
        {
          likeable_id: venue.id,
          likeable_type: 'Venue'
        }
      end

      it 'creates like for venue' do
        expect {
          post likes_path, params: venue_params
      }.to change(Like, :count).by(1)
      end

      it 'increments venue likes_count' do
        expect {
          post likes_path, params: venue_params
      }.to change { venue.reload.likes_count }.by(1)
      end
    end

    # context 'liking a Review' do
    #   let(:review_params) do
    #     {
    #       likeable_id: review.id,
    #       likeable_type: 'Review'
    #     }
    #   end

    #   it 'creates like for review' do
    #     expect {
    #       post likes_path, params: review_params
    #     }.to change(Like, :count).by(1)
    #   end

    #   it 'increments review likes_count' do
    #     expect {
    #       post likes_path, params: review_params
    #     }.to change { review.reload.likes_count }.by(1)
    #   end
    # end

    context 'when already liked(dublicate)' do
      before do
        create(:like, user: user, likeable: route)
      end

      let(:duplicate_params) do
        {
          likeable_id: route.id,
          likeable_type: 'Route'
        }
      end

      it 'does not create a duplicate like' do
        expect {
          post likes_path, params: duplicate_params
        }.not_to change(Like, :count)
      end
    end
  end

context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          post likes_path, params: { likeable_id: route.id, likeable_type: 'Route' }
          
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'does not create like' do
          sign_out user
          
          expect {
            post likes_path, params: { likeable_id: route.id, likeable_type: 'Route' }
          }.not_to change(Like, :count)
        end
      end
  end

  context 'ActionCable broadcast' do
    it 'broadcasts notification to content owner' do
      owner = route.user

      expect {
        post likes_path, params: { likeable_id: route.id, likeable_type: 'Route' }
      }.to have_broadcasted_to("notifications_#{owner.id}")
    end
  end
end

describe 'DELETE /likes/:id' do
  let!(:like) { create(:like, user: user, likeable: route) }

  context 'when user owns the like' do
    it 'destroys the like' do
      expect {
        delete like_path(like)
    }.to change(Like, :count).by(-1)
    end

    it 'decrements route likes_count' do
      expect {
        delete like_path(like)
    }.to change { route.reload.likes_count }.by(-1)
    end

    it 'redirects back with success notice' do
      delete like_path(like)

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('いいねを取り消しました')
    end
  end
end

describe 'Integration: Like -> Unlike flow' do
  it 'creates like, then removes it' do

    # Like
    post liks_path, params: { likeable_id: route.id, likeable_type: 'Route' }
    like = Like.last
    expect(like.user).to eq(user)
    expect(like.likeable).to eq(route)

    #Unlike
    delete like_path(like)
    expect(Like.where(ik: like.id).count).to eq(0)
  end
end

describe 'Polymorphic associations' do
  it 'handles likes for different types correctly' do
    # Like Route
    post likes_path, params: { likeable_id: route.id, likeable_type: 'Route' }
    route_like = Like.last
    expect(route_like.likeable_type).to eq('Route')

    # Like Venue
    post likes_path, params: { likeable_id: venue.id, likeable_type: 'Venue' }
    venue_like = Like.last
    expect(venue_like.likeable_type).to eq('Venue')   
       
    expect(user.likes.count).to eq(2)
  end
end