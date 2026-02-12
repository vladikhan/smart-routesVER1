require 'rails_helper'

RSpec.describe Venue, type: :model do
  it 'has a valid factory' do
    expect(build(:venue)).to be_valid
  end

  describe '#set_defaults' do
    it 'initializes counters/status for new records' do
      venue = Venue.new
      venue.valid?
      expect(venue.view_count).to eq(0)
      expect(venue.save_count).to eq(0)
      expect(venue.popularity_score).to eq(0.0)
      expect(venue.reviews_count).to eq(0)
      expect(venue.likes_count).to eq(0)
      # status has a DB default ('pending') in this app
      expect(venue.status).to eq('pending')
    end
  end

  describe '#liked_by?' do
    it 'returns false when user is nil' do
      venue = create(:venue)
      expect(venue.liked_by?(nil)).to be false
    end
  end

  describe '#bookmarked_by?' do
    it 'returns false when user is nil' do
      venue = create(:venue)
      expect(venue.bookmarked_by?(nil)).to be false
    end
  end
end
