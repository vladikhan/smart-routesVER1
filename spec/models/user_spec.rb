require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    
    it 'should validate uniqueness of username case-insensitively' do
      create(:user, username: 'testuser', email: 'test1@example.com')
      duplicate = build(:user, username: 'TESTUSER', email: 'test2@example.com')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:username]).to include('はすでに存在します')
    end
  end
  
  describe 'アソシエーション' do
    it { should have_many(:routes) }
    it { should have_many(:notifications) }
  end
  
  describe 'メソッド' do
    describe '#unread_notifications_count' do
      let(:user) { create(:user) }
      let(:actor) { create(:user) }
      
      before do
        create_list(:notification, 3, :unread, user: user, actor: actor)
        create_list(:notification, 2, :read, user: user, actor: actor)
      end
      
      it '未読通知の数を返す' do
        expect(user.unread_notifications_count).to eq(3)
      end
    end
  end
end
