
require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do

  let(:user) { create(:user) }

  let(:actor) { create(:user) }

  let!(:notification) { create(:notification, user: user, actor: actor) }

  

  before { sign_in user }

  

  describe 'GET #index' do

    let!(:notifications) do

      3.times.map do

        create(:notification, 

               user: user, 

               actor: actor,

               notification_type: ['like', 'follow', 'comment'].sample)

      end

    end

    

    it 'returns success' do

      get :index

      expect(response).to have_http_status(:success)

    end

    

    it 'assigns user notifications' do

      get :index

      expect(assigns(:notifications).map(&:user_id).uniq).to eq([user.id])

    end

  end

  

  describe 'GET #unread_count' do

    before do

      3.times { create(:notification, user: user, actor: actor, is_read: false) }

      2.times { create(:notification, user: user, actor: actor, is_read: true) }

    end

    

    it 'returns unread count' do

      get :unread_count, format: :json

      json = JSON.parse(response.body)

      expect(json['count']).to eq(3)

    end

    

    it 'returns JSON' do

      get :unread_count, format: :json

      expect(response.content_type).to include('application/json')

    end

  end

  

  describe 'PATCH #mark_as_read' do

    it 'marks notification as read' do

      patch :mark_as_read, params: { id: notification.id }, format: :json

      notification.reload

      expect(notification.is_read).to be true

    end

    

    it 'returns success' do

      patch :mark_as_read, params: { id: notification.id }, format: :json

      json = JSON.parse(response.body)

      expect(json['success']).to be true

    end

  end

  

  describe 'PATCH #mark_all_as_read' do

    before do

      5.times { create(:notification, user: user, actor: actor, is_read: false) }

    end

    

    it 'marks all as read' do

      patch :mark_all_as_read, format: :json

      expect(user.notifications.where(is_read: false).count).to eq(0)

    end

    

    it 'returns success' do

      patch :mark_all_as_read, format: :json

      json = JSON.parse(response.body)

      expect(json['success']).to be true

    end

  end

end

