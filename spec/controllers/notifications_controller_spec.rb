require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let(:actor) { create(:user, username: 'actor', email: 'actor@example.com') }
  let!(:notification) { create(:notification, user: user, actor: actor) }
  
  before { sign_in user }
  
  describe 'GET #index' do
    let!(:notifications) do
      3.times.map do |i|
        create(:notification, 
               user: user, 
               actor: actor,
               notification_type: ['like', 'follow', 'comment'].sample)
      end
    end
    
    it 'ユーザーの通知を返す' do
      get :index
      expect(assigns(:notifications)).to match_array(user.notifications)
    end
  end
  
  describe 'GET #unread_count' do
    before do
      3.times do
        create(:notification, user: user, actor: actor, is_read: false)
      end
      2.times do
        create(:notification, user: user, actor: actor, is_read: true)
      end
    end
    
    it '未読数を返す' do
      get :unread_count, format: :json
      expect(JSON.parse(response.body)['count']).to eq(3)
    end
  end
  
  describe 'PATCH #mark_as_read' do
    it '通知を既読にする' do
      patch :mark_as_read, params: { id: notification.id }, format: :json
      notification.reload
      expect(notification.is_read).to be true
    end
  end
  
  describe 'PATCH #mark_all_as_read' do
    before do
      3.times { create(:notification, user: user, actor: actor, is_read: false) }
    end
    
    it 'すべての通知を既読にする' do
      patch :mark_all_as_read, format: :json
      expect(user.notifications.where(is_read: false).count).to eq(0)
    end
  end
end
