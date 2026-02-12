# spec/channels/dm_room_channel_spec.rb
require 'rails_helper'

RSpec.describe DmRoomChannel, type: :channel do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:room) { create(:dm_room, sender: user, receiver: other_user) }

  before do
    stub_connection current_user: user
  end

  describe '#subscribed' do
    context 'when user is room participant' do
      it 'successfully subscribes to the stream' do
        subscribe(room_id: room.id)
        
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("dm_room_#{room.id}")
      end

      it 'broadcasts user_joined event' do
        expect {
          subscribe(room_id: room.id)
        }.to have_broadcasted_to("dm_room_#{room.id}")
          .with(hash_including(action: 'user_joined', user_id: user.id))
      end
    end

    context 'authorization: when user is not room participant' do
      let(:stranger) { create(:user) }
      
      before do
        stub_connection current_user: stranger
      end

      it 'rejects subscription' do
        subscribe(room_id: room.id)
        
        expect(subscription).to be_rejected
      end
    end

    context 'when not authenticated' do
      before do
        stub_connection current_user: nil
      end

      it 'rejects subscription' do
        subscribe(room_id: room.id)
        
        expect(subscription).to be_rejected
      end
    end
  end

  describe '#unsubscribed' do
    before { subscribe(room_id: room.id) }

    it 'broadcasts user_left event' do
      expect {
        subscription.unsubscribe_from_channel
      }.to have_broadcasted_to("dm_room_#{room.id}")
        .with(hash_including(action: 'user_left', user_id: user.id))
    end
  end

  describe '#typing' do
    before { subscribe(room_id: room.id) }

    it 'broadcasts typing indicator to other user' do
      expect {
        perform :typing, { typing: true }
      }.to have_broadcasted_to("dm_room_#{room.id}")
        .with(hash_including(
          action: 'typing',
          user_id: user.id,
          username: user.username,
          typing: true
        ))
    end

    it 'broadcasts stop typing when false' do
      expect {
        perform :typing, { typing: false }
      }.to have_broadcasted_to("dm_room_#{room.id}")
        .with(hash_including(typing: false))
    end
  end

  describe '#mark_as_read' do
    let!(:unread_messages) do
      create_list(:dm_message, 3, dm_room: room, user: other_user, is_read: false)
    end
    
    before do
      subscribe(room_id: room.id)
      room.update(unread_count_sender: 3)
    end

    it 'marks messages as read' do
      perform :mark_as_read
      
      expect(room.dm_messages.where(is_read: false).count).to eq(0)
    end

    it 'resets unread counter' do
      perform :mark_as_read
      
      expect(room.reload.unread_count_sender).to eq(0)
    end

    it 'broadcasts read status to sender' do
      expect {
        perform :mark_as_read
      }.to have_broadcasted_to("dm_room_#{room.id}")
        .with(hash_including(
          action: 'messages_read',
          reader_id: user.id
        ))
    end
  end

  describe 'integration: new message broadcast' do
    before { subscribe(room_id: room.id) }

    it 'receives new message via broadcast' do
      message = create(:dm_message, dm_room: room, user: other_user)
      
      expect {
        ActionCable.server.broadcast(
          "dm_room_#{room.id}",
          {
            action: 'new_message',
            message: {
              id: message.id,
              content: message.message,
              sender_id: other_user.id,
              sender_name: other_user.username,
              created_at: message.created_at.iso8601
            }
          }
        )
      }.to have_broadcasted_to("dm_room_#{room.id}")
    end
  end
end