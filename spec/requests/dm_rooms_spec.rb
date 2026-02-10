require 'rails_helper'

RSpec.describe 'DmRooms', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:third_user) { create(:user) }
  
  before { sign_in user }
  
  describe 'GET /dm_rooms' do
    let!(:room_as_sender) { create(:dm_room, sender: user, receiver: other_user) }
    let!(:room_as_receiver) { create(:dm_room, sender: third_user, receiver: user) }
    let!(:other_user) { create(:dm_room) }

    context 'when logged in' do
      it 'returns success' do
        get dm_rooms_path

        expect(response).to have_http_status(:success)
      end

      it 'assigns dm_rooms for current user' do
        get dm_rooms_path

        expect(assigns(:dm_rooms)).to include(room_as_sender, room_as_receiver)
        expect(assigns(:dm_rooms)).not_to include(other_room)
      end

      it 'includes sender and receiver to avoid N+1 queries' do
        get dm_rooms_path

        expect(assigns(:dm_rooms).first.sender).to be_present
        expect(assigns(:dm_rooms).first.receiver).to be_present
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_in user }

        it 'redirects to login' do
          get dm_rooms_path

          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when email not verified' do
        before do 
          user.update(email_verified: false)
          allow_any_instance_of(ApplicationController).to receive(:check_email_verification).and_call_original
        end

        it 'redirects to email verification' do
          get dm_rooms_path

          expect(response).to redirect_to(email_verification_path)
          expect(flash[:alert]).to eq('メールアドレスの確認が必要です。')
        end
      end
    end
  end

  describe 'GET /dm_rooms/:id' do
    let!(:room) { create(:dm_room, sender: user, receiver: other_user) }
    let!(:messages) { create_list(:dm_messages, 5, dm_room: room, user: other_user) }

    context 'when user is room participant' do
      it 'returns success' do
        it 'returns success' do
          get dm_room_path(room)

          expect(response).to have_http_status(:success)
        end

        it 'assigns active_room' do
          get dm_room_path(room)
          expect(assigns(:active_room)).to eq(room)
        end
      end
    end

    context 'authorization: when is not room participant' do
      let(:stranger) { create(:user) }

      before { sign_in stranger }

      it 'does not show messages' do
        get dm_room_path(room)

        expect(assigns(:messages)).to eq([])
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirectss to login' do
          get dm_room_path(room)

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'POST /dm_rooms' do
    let(:valid_params) do
      { receiver_id: other_user.id }
    end

    context 'when room does not exist yet' do
      it 'create a new dm_room' do
        expect {
          post dm_rooms_path, params: valid_params
      }.to change(DmRoom, :count).by(1)
      end

      it 'creates room with correct sender and receiver' do
        post dm_rooms_path, params: valid_params

        room = DmRoom.last
        expect(room.sender_id).to eq(user.id)
        expect(room.receiver_id).to eq(other_user.id)
      end

      it 'redirects to the new room' do
        post dm_rooms_path, params: valid_params

        room = DmRoom.last
        expect(response).to redirect_to(dm_room_path(room))
      end
    end

    context 'when room already exist' do
      let!(:existing_room) { create(:dm_room, sender: user, receiver: other_user) }

      it 'does not duplicate room' do
        expect{
          post dm_room_path, params: valid_params
      }.not_to change(DmRoom, :count)
      end
      
      it 'redirects to existing room' do
        post dm_room_path, params: valid_params

        expect(response).to redirect_to(dm_room_path(existing_room))
      end
    end

    context 'with invalid receiver_id' do
      let(:invalid_params) do
        { receiver_id: 999999 }
      end

      it 'does not create room' do
        expect {
          post dm_rooms_path, params: invalid_params
      }.not_to change(DmRoom, :count)
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_in user }

        it 'redirects to login' do 
          post dm_rooms_path, params: valid_params

          expect(response).to redirect_to(new_user_session_path)
        end
    end
  end
  end
end
