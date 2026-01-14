class DmRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :sent_dm_rooms, only: %i[index show]
  before_action :set_active_room, only: %i[show mark_all_as_read]

  def index
    @dm_rooms = DmRoom.for_user_with_preloads(current_user)
    @active_room = @dm_rooms.first

    if @active_room
      @messages = load_messages_for_room(@active_room)
      @active_room.mark_all_as_read_for(current_user)
    else
      @messages = []
    end
  end

  def show
    @dm_rooms = DmRoom.for_user_with_preloads(current_user)
    @messages = load_messages_for_room(@active_room)

    @active_room.mark_all_as_read_for(current_user)
    render :index
  end

  def create
    receiver = User.find(params[:receiver_id])

    @dm_room = DmRoom.find_or_create_between(current_user, receiver)

    redirect_to dm_room_path(@dm_room), notice: 'チャットを開始しました'
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'ユーザーが見つかりません'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: e.message
  end

  def mark_all_as_read
    @active_room.reset_unread_for(current_user)
    head :ok
  end

  def sent
    @dm_rooms = DmRoom.where(sender_id: current_user.id)
                      .includes(:sender, :receiver, dm_messages: [:user])
                      .recent
    render :index
  end

  private

  def sent_dm_rooms
    @dm_rooms = current_user.dm_rooms
                            .includes(:sender, :receiver)
                            .order(last_message_at: :desc)
  end

  def set_active_room
    @active_room = DmRoom.find(params[:id])
  end

  def prepare_active_room_data
    @messages = @active_room.dm_messages
                            .includes(:user)
                            .order(created_at: :asc)
    # Make counters == 0
    @active_room.reset_unread_for(current_user)

    # Refresh counters
    @active_room.dm_messages.unread_by(current_user).update_all(
      is_read: true,
      read_at: Time.current
    )
  end

  def authorize_room_access
    return if @active_room.sender_id == current_user.id || @active_room.receiver_id == current_user.id

    redirect_to dm_rooms_path, alert: 'アクセス権限がありません'
  end
end

def load_messages_for_room(room)
  room.dm_messages
      .includes(:user)
      .order(created_at: :asc)
      .limit(100)
end
