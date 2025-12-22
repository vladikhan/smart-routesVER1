# Encoding: UTF-8
require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }
  let(:actor) { create(:user) }
  
  describe 'バリデーション' do
    it '有効なファクトリを持つ' do
      notification = build(:notification, user: user, actor: actor)
      expect(notification).to be_valid
    end
  end
  
  describe 'スコープ' do
    let!(:unread1) { create(:notification, :unread, user: user, actor: actor) }
    let!(:unread2) { create(:notification, :unread, user: user, actor: actor) }
    let!(:read1) { create(:notification, :read, user: user, actor: actor) }
    
    it '未読通知のみを返す' do
      unread = Notification.unread.to_a
      expect(unread).to include(unread1, unread2)
      expect(unread).not_to include(read1)
    end
    
    it '既読通知のみを返す' do
      read = Notification.read.to_a
      expect(read).to include(read1)
      expect(read).not_to include(unread1, unread2)
    end
  end
  
  describe 'メソッド' do
    let(:notification) { create(:notification, user: user, actor: actor, notification_type: 'like') }
    
    it '#message 正しいメッセージを返す' do
      expect(notification.message).to include(actor.username)
    end
    
    it '#icon 正しいアイコンを返す' do
      expect(notification.icon).to eq('❤️')
    end
    
    it '#mark_as_read 既読にする' do
      notification.mark_as_read!
      expect(notification.reload.is_read).to be true
    end
  end
end
