require 'rails_helper'

RSpec.describe Route, type: :model do
  let(:user) { create(:user) }
  let(:city) { create(:city) }
  
  describe 'validations' do
    it 'is valid with valid attributes' do
      route = build(:route, user: user, city: city)
      expect(route).to be_valid
    end
    
    it 'requires name' do
      route = build(:route, name: nil, user: user, city: city)
      expect(route).not_to be_valid
    end
    
    it 'requires city' do
      route = build(:route, city: nil, user: user)
      expect(route).not_to be_valid
    end
    
    it 'requires user' do
      route = build(:route, user: nil, city: city)
      expect(route).not_to be_valid
    end
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:city) }
    it { should have_many(:route_items) }
    it { should have_many(:venues).through(:route_items) }
  end
  
  describe 'scopes' do
    let!(:public_route) { create(:route, is_public: true, user: user, city: city) }
    let!(:private_route) { create(:route, is_public: false, user: user, city: city) }
    
    it 'returns only public routes' do
      expect(Route.public_routes).to include(public_route)
      expect(Route.public_routes).not_to include(private_route)
    end
  end
  
  describe '#increment_view_count' do
    it 'increments view count' do
      route = create(:route)
      expect {
        route.increment_view_count!
      }.to change { route.reload.view_count }.by(1)
    end
  end
end