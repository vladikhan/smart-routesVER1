require 'rails_helper'

RSpec.describe DmMessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:room) { create(:dm_room, sender: user, receiver: other_user) }
  
  before { sign_in user }

  describe 'POST #create' do
    let(:valid_params) do
      {
        dm_room_id: room.id,
        dm_message: { text: 'こんにちは！' }
      }
    end

    context 'with valid params' do
      it 'creates a new message' do
        expect {
          post :create, params: valid_params, format: :js
        }.to change(DmMessage, :count).by(1)
      end

      it 'creates message with correct attributes' do
        post :create, params: valid_params, format: :js
        
        message = DmMessage.last
        expect(message.message).to eq('こんにちは！')
        expect(message.user).to eq(user)
        expect(message.dm_room).to eq(room)
      end

      it 'broadcasts message via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "dm_room_#{room.id}",
          hash_including(
            message: hash_including(
              content: 'こんにちは！',
              sender_id: user.id
            )
          )
        )
        
        post :create, params: valid_params, format: :js
      end

      it 'returns success response' do
        post :create, params: valid_params, format: :js
        
        expect(response).to have_http_status(:success)
      end

      it 'updates room last_message_at' do
        freeze_time do
          post :create, params: valid_params, format: :js
          
          expect(room.reload.last_message_at).to eq(Time.current)
        end
      end

      it 'increments receiver unread count' do
        expect {
          post :create, params: valid_params, format: :js
        }.to change { room.reload.unread_count_receiver }.by(1)
      end
    end

    context 'with emoji message' do
      let(:emoji_params) do
        {
          dm_room_id: room.id,
          dm_message: { text: 'お疲れ様です！ 😊🎉✨' }
        }
      end

      it 'correctly saves emoji' do
        post :create, params: emoji_params, format: :js
        
        message = DmMessage.last
        expect(message.message).to include('😊')
        expect(message.message).to include('🎉')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          dm_room_id: room.id,
          dm_message: { text: '' }
        }
      end

      it 'does not create message' do
        expect {
          post :create, params: invalid_params, format: :js
        }.not_to change(DmMessage, :count)
      end

      it 'returns error response' do
        post :create, params: invalid_params, format: :js
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'authorization checks' do
      context 'when user is not room participant' do
        let(:stranger) { create(:user) }
        
        before { sign_in stranger }

        it 'denies access' do
          post :create, params: valid_params, format: :js
          
          expect(response).to have_http_status(:forbidden)
        end

        it 'does not create message' do
          expect {
            post :create, params: valid_params, format: :js
          }.not_to change(DmMessage, :count)
        end
      end

      context 'when user is banned' do
        before { user.update(is_banned: true) }

        it 'denies access' do
          post :create, params: valid_params, format: :js
          
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          post :create, params: valid_params, format: :js
          
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when message esceeds max length' do
      let(:long_params) do
        {
          dm_room_id: room.id,
          dm_message: { text: 'あ' * 5001 }
        }
      end

      it 'returns validation error' do
        post :create, params: long_params, format: :js 

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('メッセージは5000文字以内で入力してください')
      end
    end
  end

  describe 'PATCH #update' do
  let(:message) { create(:dm_message, dm_room: room, user: user) }
  let(:update_params) do
    {
      dm_room_id: room.id,
      id: message.id,
      dm_message: { text: '編集しました' }
    }
  end

  context 'when user owns the message' do
      it 'updates the message' do
        patch :update, params: update_params, format: :js
        
        expect(message.reload.message).to eq('編集しました')
      end

      it 'broadcasts update via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "dm_room_#{room.id}",
          hash_including(action: 'update')
        )
        
        patch :update, params: update_params, format: :js
      end
    end

    context 'authorization: when user does not own the message' do
      let(:other_message) { create(:dm_message, dm_room: room, user: other_user) }
      let(:unauthorized_params) do
        {
          dm_room_id: room.id,
          id: other_message.id,
          dm_message: { text: 'ハッキング試行' }
        }
      end

      it 'denies access' do
        patch :update, params: unauthorized_params, format: :js
        
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update the message' do
        original_text = other_message.message
        patch :update, params: unauthorized_params, format: :js
        
        expect(other_message.reload.message).to eq(original_text)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:message) { create(:dm_message, dm_room: room, user: user) }
    let(:delete_params) { { dm_room_id: room.id, id: message.id } }

    context 'when user owns the message' do
      it 'deletes the message' do
        expect {
          delete :destroy, params: delete_params, format: :js
        }.to change(DmMessage, :count).by(-1)
      end

      it 'broadcasts deletion via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "dm_room_#{room.id}",
          hash_including(action: 'delete', message_id: message.id)
        )
        
        delete :destroy, params: delete_params, format: :js
      end
    end

    context 'authorization: when user does not own the message' do
      let!(:other_message) { create(:dm_message, dm_room: room, user: other_user) }
      let(:unauthorized_params) { { dm_room_id: room.id, id: other_message.id } }

      it 'denies access' do
        delete :destroy, params: unauthorized_params, format: :js
        
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not delete the message' do
        expect {
          delete :destroy, params: unauthorized_params, format: :js
        }.not_to change(DmMessage, :count)
      end
    end
  end
end
