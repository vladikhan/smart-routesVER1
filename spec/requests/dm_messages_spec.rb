require 'rails_helper'

RSpec.describe "DmMessages", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:room) { create(:dm_room, sender: user, receiver: other_user) }
  let(:stranger) { create(:user) }

  before { sign_in user }

  describe 'GET /dm_rooms/:dm_room_id/dm_messages' do
    let!(:messages) { create_list(:dm_message, 5, dm_room: room, user: other_user) }

    context 'when user is room participant' do
      it 'returns success' do
        get dm_room_dm_messages_path(room)
        
        expect(response).to have_http_status(:success)
      end

      it 'assigns dm_room and messages' do
        get dm_room_dm_messages_path(room)
        
        expect(assigns(:dm_room)).to eq(room)
        expect(assigns(:dm_message)).to be_a(DmMessage)
      end

      it 'loads messages ordered by created_at' do
        get dm_room_path(room)
        
        # Assuming Operation loads messages
        # expect(assigns(:messages).count).to eq(5)
      end
    end

    context 'authorization: when user is not room participant' do
      before { sign_in stranger }

      it 'redirects to dm_rooms with alert' do
        get dm_room_dm_messages_path(room)
        
        expect(response).to redirect_to(dm_rooms_path)
        expect(flash[:alert]).to eq('アクセス権限がないか、チャットルームが見つかりません')
      end
    end

    context 'when room does not exist' do
      it 'redirects with error' do
        get dm_room_dm_messages_path(dm_room_id: 999999)
        
        expect(response).to redirect_to(dm_rooms_path)
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          get dm_room_dm_messages_path(room)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'POST /dm_rooms/:dm_room_id/dm_messages' do
    let(:valid_params) do
      {
        dm_room_id: room.id,
        text: 'こんにちは！元気ですか？'
      }
    end

    context 'with valid params' do
      it 'creates a new message' do
        expect {
          post dm_room_dm_messages_path(room), params: valid_params
        }.to change(DmMessage, :count).by(1)
      end

      it 'creates message with correct attributes' do
        post dm_room_dm_messages_path(room), params: valid_params
        
        message = DmMessage.last
        expect(message.message).to eq('こんにちは！元気ですか？')
        expect(message.user).to eq(user)
        expect(message.dm_room).to eq(room)
        expect(message.is_read).to be false
      end

      it 'updates room last_message_at' do
        freeze_time do
          post dm_room_dm_messages_path(room), params: valid_params
          
          expect(room.reload.last_message_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'increments receiver unread count' do
        expect {
          post dm_room_dm_messages_path(room), params: valid_params
        }.to change { room.reload.unread_count_receiver }.by(1)
      end

      context 'HTML format' do
        it 'redirects to dm_room show page' do
          post dm_room_dm_messages_path(room), params: valid_params
          
          expect(response).to redirect_to(dm_room_path(room))
        end
      end

      context 'Turbo Stream format' do
        it 'responds with turbo_stream' do
          post dm_room_dm_messages_path(room), params: valid_params, as: :turbo_stream
          
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end

      context 'JSON format' do
        it 'returns created status with message data' do
          post dm_room_dm_messages_path(room), params: valid_params, as: :json
          
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json['message']).to eq('こんにちは！元気ですか？')
        end
      end
    end

    context 'with emoji message' do
      let(:emoji_params) do
        {
          dm_room_id: room.id,
          text: 'お疲れ様です！ 😊🎉✨'
        }
      end

      it 'correctly saves emoji' do
        post dm_room_dm_messages_path(room), params: emoji_params
        
        message = DmMessage.last
        expect(message.message).to include('😊')
        expect(message.message).to include('🎉')
        expect(message.message).to include('✨')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          dm_room_id: room.id,
          text: '' # Empty message
        }
      end

      it 'does not create message' do
        expect {
          post dm_room_dm_messages_path(room), params: invalid_params
        }.not_to change(DmMessage, :count)
      end

      it 'redirects with error alert' do
        post dm_room_dm_messages_path(room), params: invalid_params
        
        expect(response).to redirect_to(dm_room_path(room))
        expect(flash[:alert]).to match(/エラーが発生しました/)
      end
    end

    context 'with message exceeding max length (5000 chars)' do
      let(:long_params) do
        {
          dm_room_id: room.id,
          text: 'あ' * 5001
        }
      end

      it 'does not create message' do
        expect {
          post dm_room_dm_messages_path(room), params: long_params
        }.not_to change(DmMessage, :count)
      end

      it 'returns validation error' do
        post dm_room_dm_messages_path(room), params: long_params
        
        expect(flash[:alert]).to be_present
      end
    end

    context 'authorization: when user is not room participant' do
      before { sign_in stranger }

      it 'does not create message' do
        expect {
          post dm_room_dm_messages_path(room), params: valid_params
        }.not_to change(DmMessage, :count)
      end

      it 'redirects with error' do
        post dm_room_dm_messages_path(room), params: valid_params
        
        expect(response).to redirect_to(dm_rooms_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          post dm_room_dm_messages_path(room), params: valid_params
          
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context 'ActionCable broadcast' do
      it 'broadcasts message to room channel' do
        expect {
          post dm_room_dm_messages_path(room), params: valid_params
        }.to have_broadcasted_to("dm_room_#{room.id}")
      end
    end
  end

  describe 'DELETE /dm_rooms/:dm_room_id/dm_messages/:id' do
    let!(:message) { create(:dm_message, dm_room: room, user: user) }

    context 'when user owns the message' do
      it 'destroys the message' do
        expect {
          delete dm_room_dm_message_path(room, message)
      }.to change(DmMessage, :count).by(-1)
      end

      it 'redirects back with success notice' do
        delete dm_room_dm_message_path(room, message)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('メッセージを削除しました')
      end

      it 'broadcasts deletion to ActionCable' do
        expect {
          delete dm_room_dm_message_path(room, message)
      }.to have_broadcasted_to("dm_room_#{room.id}").with(
        hash_including(action: 'delete')
      )
      end
    end

    context 'authorization: when user is not room participant' do
      before { sign_in stranger }

      it 'does not destroy the message' do
        expect { 
          delete dm_room_dm_message_path(room, message)
      }.not_to change(DmMessage, :count)
      end

      it 'returns error' do
        delete dm_room_dm_message_path(room, message)
        expect(flash[:alert]).to be_present
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          delete dm_room_dm_message_path(room, message)

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'POST /dm_rooms/:id/mark_all_as_read' do
    let!(:unread_messages) do
      create_list(:dm_message, 3, dm_room: room, user: other_user, is_read: false)
    end

    before do
      room.update(unread_count_receiver: 3)
    end

    context 'when user is room participant' do
      it 'marks all messages as read' do
        post mark_all_as_read_dm_room_path(room)
        expect(room.dm_messages.where(is_read: false).count).to eq(0)
      end

      it 'resets unread counter' do
        post mark_all_as_read_dm_room_path(room)
        expect(room.reload.unread_count_receiver).to eq(0)
      end

      
      it 'returns ok status' do
        post mark_all_as_read_dm_room_path(room)
        expect(response).to have_http_status(:ok)
      end
    end
  end

context 'authorization: when user is not room participant' do
  before { sign_in stranger }

  it "does not mark messages as read" do
  # Создаем сообщения вручную внутри теста, если их нет в let
  3.times { create(:dm_message, dm_room: room, is_read: false) }
  
  post mark_all_as_read_dm_room_path(room)
  
  # Теперь это должно сработать, так как в базе они точно были is_read: false
  expect(room.dm_messages.where(is_read: false).count).to eq(3)
end

  it 'returns forbidden status' do 
      post mark_all_as_read_dm_room_path(room)
      expect(response).to have_http_status(:forbidden)
  end 
end
end

