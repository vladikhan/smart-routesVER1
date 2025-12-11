# encoding: UTF-8
require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:notification_type) }
    it { should validate_presence_of(:notification_type).in_array(&w[follow comment review route_shared]) }
  end

  describe 'アソシエーション' do
    it { should belong_to(:user) }
    it { should belong_to(:actor).class_name(('User')) }
  end

  describe 'スコープ' do
    let(:user) { create(:user) }
    let!(:unread) { create_list(:notification, 3, user: user) }
    let!(:read) { create_list(:notification, 2, :read, user: user) }

    it '未読通知のみを返す' do
      expect(user.notification.unread.count).to eq(3)
    end
    it '既読通知のみを返す' do
      expect(user.notification.read.count).to eq(2)
    end
  end

  describe 'メソッド' do
    let(:notification) { create(:notification, notificaiton_type: 'like') }

    describe '#message' do
      it '正しいメッセージを返す' do
        expect(notificaiton.message).to include('いいねしました')
    end
  end

  describe '#icon' do
    it '正しいアイコンを返す' do
      expect(notification.icon).to eq('❤️')
    end
  end

  describe '#mark_as_read' do
    it '既読にする' do
          expect {
            notification.maek_as_read!
        }.to change { notificaiton.reload.is_read }.from(false).to(true)
      end
    end
  end     
end