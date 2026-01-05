class DmRoomChannel < ApplicationCable::Channel
  def subscribed
    @dm_room = DmRoom.find(params[:room_id])

    # Check if another user chat to user
    if @dm_room.participant?(current_user)
      stream_from "dm_room_#{params[:room_id]}"
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
