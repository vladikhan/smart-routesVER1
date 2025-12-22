# spec/requests/notifications_spec.rb
require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  
  before do
    sign_in user  # Для request specs
  end

  describe "GET /notifications" do
    it "показывает уведомления" do
      notification = create(:notification, user: user)
      get notifications_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /notifications/unread_count" do
    it "возвращает количество непрочитанных" do
      create_list(:notification, 3, user: user, is_read: false)
      create_list(:notification, 2, user: user, is_read: true)
      
      get unread_count_notifications_path
      json = JSON.parse(response.body)
      expect(json['count']).to eq(3)
    end
  end

  describe "PATCH /notifications/:id/mark_as_read" do
    it "помечает как прочитанное" do
      notification = create(:notification, user: user, is_read: false)
      
      patch mark_as_read_notification_path(notification), 
            params: {}, 
            as: :json
      
      notification.reload
      expect(notification.is_read).to be true
    end
  end

  describe "PATCH /notifications/mark_all_as_read" do
    it "помечает все как прочитанные" do
      create_list(:notification, 6, user: user, is_read: false)
      
      patch mark_all_as_read_notifications_path, 
            params: {}, 
            as: :json
      
      expect(user.notifications.where(is_read: false).count).to eq(0)
    end
  end
end