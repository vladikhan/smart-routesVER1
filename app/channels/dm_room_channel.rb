class DmRoomChannel < ApplicationCable::Channel
  def subscribed
    @dm_room = DmRoom.find(params[:room_id])

    # Check if another user chat to user
    if @dm_room.participant?(current_user)
      stream_from "dm_room_#{params[:room_id]}"

      ActionCable.server.broadcast(
        "dm_room_#{@dm_room.id}",
        { action: 'user_joined', user_id: current_user.id }
      )
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams

    return unless defined?(@dm_room) && @dm_room && current_user

    ActionCable.server.broadcast(
      "dm_room_#{@dm_room.id}",
      { action: 'user_left', user_id: current_user.id }
    )
  end

  def typing(data)
    return unless defined?(@dm_room) && @dm_room && current_user

    ActionCable.server.broadcast(
      "dm_room_#{@dm_room.id}",
      {
        action: 'typing',
        user_id: current_user.id,
        username: current_user.username,
        typing: !!data['typing']
      }
    )
  end

  def mark_as_read
    return unless defined?(@dm_room) && @dm_room && current_user

    @dm_room.mark_all_as_read_for(current_user)

    ActionCable.server.broadcast(
      "dm_room_#{@dm_room.id}",
      { action: 'messages_read', reader_id: current_user.id }
    )
  end
end
