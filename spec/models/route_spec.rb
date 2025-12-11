# Encoding: UTF-8
require 'rails_helper'

RSpec.describe Route, type: :model do
  describe 'バリデーション' do 
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:city) }
  end

  describe 'アソシエーション' do
it { should belong_to(:user) }
it { should belong_to(:city) } 
it { should have_many(:route_items).dependent(:destroy) }
it { should have_many(:tags).through(:entity_tags) }   
  end

  describe 'スコープ' do
    let!(:public_route) { create(:route, is_public: true)}
    let!(:private_route) { create(:route, :private) } 

    it '公開ルートのみを返す' do
      expect(Route.where(is_public: true)).to include(public_route) 
      expect(Route.where(is_public: true)).not_to include(private_route)      
    end
  end
end
