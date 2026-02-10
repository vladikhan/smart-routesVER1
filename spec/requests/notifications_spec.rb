require 'rails_helper'

RSpec.describe 'Notifications', type: :request do
  let(:user) { create(:user) }
  let(:actor) { create(:user) }
  
  before { sign_in user }

  describe 'GET /notifications' do
    # Используем let! чтобы уведомления создались до вызова get
    let!(:message_notification) { create(:notification, :new_message, user: user, actor: actor) }
    let!(:follow_notification)  { create(:notification, :follow_request, user: user, actor: actor) }
    let!(:like_notification)    { create(:notification, :route_liked, user: user, actor: actor) }

    it 'returns success and shows notifications' do
      get notifications_path
      expect(response).to have_http_status(:success)
      # Вместо assigns проверяем текст на странице
      expect(response.body).to include(message_notification.actor.name)
    end

    context 'with filter: messages' do
      it 'filters notifications by type' do
        get notifications_path, params: { filter: 'messages' }
        expect(response.body).to include('сообщение') # Или другой текст из вьюхи
      end
    end
  end

  describe 'GET /notifications/unread_count' do
    it 'returns correct JSON unread count' do
      create_list(:notification, 3, user: user, is_read: false)
      
      get unread_count_notifications_path, as: :json
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['count']).to eq(3)
    end
  end

  describe 'POST /notifications/:id/mark_as_read' do
    let!(:notification) { create(:notification, user: user, is_read: false) }

    it 'marks notification as read and redirects' do
      # Используй POST или PATCH в зависимости от твоего routes.rb
      post mark_as_read_notification_path(notification)
      
      expect(notification.reload.is_read).to be true
      expect(response).to have_http_status(:redirect)
    end

    it 'returns success JSON when requested as json' do
      post mark_as_read_notification_path(notification), as: :json
      
      json = JSON.parse(response.body)
      expect(json['success']).to be true
    end
  end

  describe 'POST /notifications/mark_all_as_read' do
    it 'clears all unread notifications for current user' do
      create_list(:notification, 5, user: user, is_read: false)
      
      post mark_all_as_read_notifications_path, as: :json
      
      expect(user.notifications.unread.count).to eq(0)
    end
  end
end

