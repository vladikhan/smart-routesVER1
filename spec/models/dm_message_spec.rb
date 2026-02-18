require 'rails_helper'

RSpec.describe DmMessage, type: :model do
  describe 'associations' do
    it { should belong_to(:dm_room) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:message) }
    
    it 'validates message length' do
      message = build(:dm_message, message: 'a' * 5001)
      expect(message).not_to be_valid
      expect(message.errors[:message]).to include('は5000文字以内で入力してください')
    end
  end

  describe 'scopes' do
    let(:room) { create(:dm_room) }
    let!(:read_message) { create(:dm_message, :read, dm_room: room) }
    let!(:unread_message) { create(:dm_message, dm_room: room) }

    it 'returns unread messages' do
      expect(DmMessage.unread).to include(unread_message)
      expect(DmMessage.unread).not_to include(read_message)
    end
  end

  describe '#mark_as_read!' do
    let(:message) { create(:dm_message, is_read: false) }

    it 'marks message as read and sets read_at timestamp' do
      freeze_time do
        message.mark_as_read!
        
        expect(message.reload.is_read).to be true
        expect(message.read_at).to eq(Time.current)
      end
    end
  end

  describe 'emoji support' do
    it 'correctly saves and retrieves emoji messages' do
      message = create(:dm_message, :with_emoji)
      
      expect(message.reload.message).to include('😊')
      expect(message.message).to include('🎉')
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      let(:room) { create(:dm_room) }
      let(:sender) { room.sender }

      it 'updates room last_message_at timestamp' do
        freeze_time do
          create(:dm_message, dm_room: room, user: sender)
          
          expect(room.reload.last_message_at).to eq(Time.current)
        end
      end

      it 'increments unread count for receiver' do
        expect {
          create(:dm_message, dm_room: room, user: sender)
        }.to change { room.reload.unread_count_receiver }.by(1)
      end

      it 'does not increment sender unread count' do
        expect {
          create(:dm_message, dm_room: room, user: sender)
        }.not_to change { room.reload.unread_count_sender }
      end
    end
  end

  describe 'avatar display logic' do
    context 'when user has image_url' do
      let(:user) { create(:user, :with_avatar) }
      let(:message) { create(:dm_message, user: user) }

      it 'uses user image_url for avatar' do
        expect(message.user.image_url).to be_present
      end
    end

    context 'when user has no image_url' do
      let(:user) { create(:user, image_url: nil) }
      let(:message) { create(:dm_message, user: user) }

      it 'falls back to placeholder with first letter' do
        expect(message.user.image_url).to be_nil
        expect(message.user.username[0].upcase).to match(/[A-Z0-9]/)
      end
    end
  end
end