# spec/models/dm_room_spec.rb
require 'rails_helper'

RSpec.describe DmRoom, type: :model do
  describe 'associations' do
    it { should belong_to(:sender).class_name('User') }
    it { should belong_to(:receiver).class_name('User') }
    it { should have_many(:dm_messages).dependent(:destroy) }
  end

  describe 'validations' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it 'does not create duplicate rooms between same users (find_or_create_between)' do
      expect {
        DmRoom.find_or_create_between(user1.id, user2.id)
        DmRoom.find_or_create_between(user1.id, user2.id)
      }.to change(DmRoom, :count).by(1)
    end

    it 'prevents self-messaging' do
      room = build(:dm_room, sender: user1, receiver: user1)
      
      expect(room).not_to be_valid
      expect(room.errors[:base]).to include('You cannot chat with yourself')
    end
  end

  describe '#other_user' do
    let(:room) { create(:dm_room) }

    it 'returns receiver when current_user is sender' do
      expect(room.other_user(room.sender)).to eq(room.receiver)
    end

    it 'returns sender when current_user is receiver' do
      expect(room.other_user(room.receiver)).to eq(room.sender)
    end
  end

  describe '#last_message' do
    let(:room) { create(:dm_room) }

    context 'when room has messages' do
      let!(:old_message) { create(:dm_message, dm_room: room, created_at: 1.hour.ago) }
      let!(:new_message) { create(:dm_message, dm_room: room, created_at: 1.minute.ago) }

      it 'returns the most recent message' do
        expect(room.last_message).to eq(new_message)
      end
    end

    context 'when room has no messages' do
      it 'returns nil' do
        expect(room.last_message).to be_nil
      end
    end
  end

  describe '#any_unread_for?' do
    let(:room) { create(:dm_room) }
    let(:user) { room.receiver }

    context 'when user has unread messages' do
      before { room.update(unread_count_receiver: 3) }

      it 'returns true' do
        expect(room.any_unread_for?(user)).to be true
      end
    end

    context 'when user has no unread messages' do
      before { room.update(unread_count_receiver: 0) }

      it 'returns false' do
        expect(room.any_unread_for?(user)).to be false
      end
    end
  end

  describe '#unread_count_for' do
    let(:room) { create(:dm_room, unread_count_sender: 2, unread_count_receiver: 5) }

    it 'returns sender unread count for sender' do
      expect(room.unread_count_for(room.sender)).to eq(2)
    end

    it 'returns receiver unread count for receiver' do
      expect(room.unread_count_for(room.receiver)).to eq(5)
    end
  end

  describe '#mark_all_as_read_for' do
    let(:room) { create(:dm_room) }
    let(:user) { room.receiver }
    
    before do
      create_list(:dm_message, 3, dm_room: room, user: room.sender, is_read: false)
      room.update(unread_count_receiver: 3)
    end

    it 'marks all messages as read' do
      room.mark_all_as_read_for(user)
      
      expect(room.dm_messages.where(is_read: false).count).to eq(0)
    end

    it 'resets unread counter' do
      room.mark_all_as_read_for(user)
      
      expect(room.reload.unread_count_receiver).to eq(0)
    end

    it 'sets read_at timestamp' do
      freeze_time do
        room.mark_all_as_read_for(user)
        
        room.dm_messages.each do |msg|
          expect(msg.read_at).to eq(Time.current)
        end
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:room_as_sender) { create(:dm_room, sender: user) }
    let!(:room_as_receiver) { create(:dm_room, receiver: user) }
    let!(:other_room) { create(:dm_room) }

    it 'returns rooms where user is participant' do
      rooms = DmRoom.for_user(user)
      
      expect(rooms).to include(room_as_sender, room_as_receiver)
      expect(rooms).not_to include(other_room)
    end

    it 'orders by last_message_at desc' do
      room_as_sender.update(last_message_at: 1.hour.ago)
      room_as_receiver.update(last_message_at: 5.minutes.ago)
      
      rooms = DmRoom.for_user(user).recent
      
      expect(rooms.first).to eq(room_as_receiver)
    end
  end
end