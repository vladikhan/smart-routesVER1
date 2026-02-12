require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  let(:user) { create(:user) }
  let(:route) { create(:route) }
  let(:venue) { create(:venue) }

  before { sign_in user }

  describe 'POST /likes' do
    context 'when liking a route' do
      let(:route_params) { { likeable_id: route.id, likeable_type: 'Route' } }

      it "creates a new like" do
        expect {
          post likes_path, params: route_params
        }.to change(Like, :count).by(1) # Проверяем, что в базе стало на +1 запись

        expect(response).to have_http_status(:redirect)
      end

      context 'when already liked (duplicate)' do
        before { create(:like, user: user, likeable: route) }

        it 'does not create a second like' do
          expect {
            post likes_path, params: route_params
          }.not_to change(Like, :count)
        end
      end
    end

    context 'when liking a venue' do
      let(:venue_params) { { likeable_id: venue.id, likeable_type: 'Venue' } }

      it 'creates like for venue' do
        expect {
          post likes_path, params: venue_params
        }.to change(Like, :count).by(1)
      end
    end
  end

  describe 'DELETE /likes/:id' do
    let!(:like) { create(:like, user: user, likeable: route) }

    it 'destroys the like' do
      expect {
        delete like_path(like)
      }.to change(Like, :count).by(-1)
    end
  end

  describe 'ActionCable broadcast' do
    it 'broadcasts notification to content owner' do
      owner = route.user
      expect {
        post likes_path, params: { likeable_id: route.id, likeable_type: 'Route' }
      }.to have_broadcasted_to("notifications_#{owner.id}")
    end
  end
end