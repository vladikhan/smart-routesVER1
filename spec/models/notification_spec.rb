require 'rails_helper'

RSpec.describe 'Notifications', type: :request do
  let(:user) { create(:user) }
  let(:actor) { create(:user) }
  let!(:notification) { create(:notification, user: user, actor: actor) }
  
  before { sign_in user }
  
  describe 'GET /notifications' do
    let!(:notifications) do
      3.times.map do
        create(:notification, 
               user: user, 
               actor: actor,
               notification_type: ['like', 'follow', 'comment'].sample)
      end
    end
    
    it 'shows notifications' do
      get notifications_path
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'GET /notifications/unread_count' do
    before do
      3.times { create(:notification, user: user, actor: actor, is_read: false) }
      2.times { create(:notification, user: user, actor: actor, is_read: true) }
    end
    
    it 'returns unread count' do
      get unread_count_notifications_path, as: :json
      json = JSON.parse(response.body)
      expect(json['count']).to eq(3)
    end
  end
  
  describe 'PATCH /notifications/:id/mark_as_read' do
    it 'marks notification as read' do
      patch mark_as_read_notification_path(notification), as: :json
      expect(notification.reload.is_read).to be true
    end
    
    it 'returns success' do
      patch mark_as_read_notification_path(notification), as: :json
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end
  end
  
  describe 'PATCH /notifications/mark_all_as_read' do
    before do
      5.times { create(:notification, user: user, actor: actor, is_read: false) }
    end
    
    it 'marks all as read' do
      patch mark_all_as_read_notifications_path, as: :json
      expect(user.notifications.where(is_read: false).count).to eq(0)
    end
  end
end