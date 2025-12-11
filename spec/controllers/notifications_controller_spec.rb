# Encoding: UTF-8
require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let(:notification) { create(:notification, user: user) }
  
  before { sign_in user }
  
  describe 'GET #index' do
    let!(:notifications) { create_list(:notification, 5, user: user) }
    
    it 'ユーザーの通知を返す' do
      get :index
      expect(assigns(:notifications)).to match_array(notifications)
    end
  end
  
  describe 'GET #unread_count' do
    before do
      create_list(:notification, 3, user: user)
      create_list(:notification, 2,:read, user: user)
    end
    
    it '未読数を返す' do
      get :unread_count, format: :json
      json = JSON.parse(response.body)
      expect(json['count']).to eq(3)
    end
  end
  
  describe 'PATCH #mark_as_read' do
    it '通知を既読にする' do
      patch :mark_as_read, params: { id: notification.id }, format: :json
      expect(notification.reload.is_read).to be true
    end
  end
  
  describe 'PATCH #mark_all_as_read' do
    before do
      create_list(:notification, 3, user: user)
    end
    
    it 'すべての通知を既読にする' do
      patch :mark_all_as_read, format: :json
      expect(user.notifications.unread.count).to eq(0)
    end
  end
end