class DmRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :sent_dm_rooms, only: %i[index show]
  before_action :set_active_room, only: %i[show mark_all_as_read]

  def index
    @active_room = params[:room_id] ? @dm_rooms.find_by(id: params[:room_id]) : @dm_rooms.first

    prepare_active_room_data if @active_room
  end

  def show
    redirect_to dm_rooms_path, alert: 'アクセス権がありません' unless @active_room.participant?(current_user)

    prepare_active_room_data

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @messages }
    end
  end

  def create
    other_user = User.find(params[:user_id])
    @dm_room = DmRoom.find_or_create_between(current_user, other_user)

    redirect_to dm_room_path(@dm_room)
  end

  def mark_all_as_read
    @active_room.reset_unread_for(current_user)
    head :ok
  end

  def sent
    sent_dm_rooms

    @active_room = @dm_rooms.first
    prepare_active_room_data if @active_room
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
end
