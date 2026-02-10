require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
  let(:user) { create(:user) }
  let(:venue) { create(:venue) }
  let(:route) { create(:route) }

  before { sign_in user }


  shared_examples 'review creation' do |reviewable_type|
    let(:reviewable) { send(reviewable_type.downcase) }
    let(:path) { reviewable_type == 'Venue' ? venue_reviews_path(venue) : route_reviews_path(route) }

    let(:valid_params) do
      { review: { text: 'とても美味しかったです！雰囲気も最高でした。' } 
    }
    end

    it "creates a new review for #{reviewable_type}" do
    expect {
      post path, params: valid_params
    }.to change { Review.count }.by(1)

    review = Review.last
    expect(review.reviewable).to eq(reviewable)
    expect(review.user).to eq(user)
    end

    it 'increments reviews_count' do
      expect {
        post path, params: valid_params
    }.to change { revieable.reload.reviews_count }.by(1)
  end

  it 'creates activity and notification' do 
    owner = reviewable.user
    expect {
      post path, params: valid_params
  }.to change(Activity, :count).by(1).and change(owner.notifications, :count).by(1)
  end
end

describe 'POST /create' do
    context 'when reviewable is Venue' do
      it_behaves_like 'review creation', 'Venue'
    end

    context 'when reviewable is Route' do
      it_behaves_like 'review creation', 'Route'
    end

    context 'with invalid params' do
      it 'does not create review and shows alert' do
        expect {
          post venue_reviews_path(venue), params: { review: { text: 'short' } }
        }.not_to change(Review, :count)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH /reviews/:id' do
    let!(:review) { create(:review, user: user, reviewable: venue, text: 'Старый текст отзыва') }

    it 'updates review text' do
      patch venue_review_path(venue, review), params: { review: { text: 'Новый обновленный текст отзыва' } }
      expect(review.reload.text).to eq('Новый обновленный текст отзыва')
      expect(response).to redirect_to(venue_path(venue))
    end
  end

  describe 'DELETE /reviews/:id' do
    let!(:review) { create(:review, user: user, reviewable: venue) }

    it 'destroys review and cleans up' do
      create_list(:like, 2, likeable: review)
      
      expect {
        delete venue_review_path(venue, review)
      }.to change(Review, :count).by(-1)
       .and change(Like, :count).by(-2)
       .and change { venue.reload.reviews_count }.by(-1)
    end
  end

  describe 'Authorization' do
    let(:other_user) { create(:user) }
    let!(:other_review) { create(:review, user: other_user, reviewable: venue) }

    it 'prevents editing someone else review' do
      get edit_venue_review_path(venue, other_review)
      expect(response).to redirect_to(venue_path(venue))
      expect(flash[:alert]).to eq('アクセス権限がありません。')
    end

    it 'prevents banned user from reviewing' do
      user.update(is_banned: true)
      expect {
        post venue_reviews_path(venue), params: { review: { text: 'Valid length text here' } }
      }.not_to change(Review, :count)
    end
  end
end
