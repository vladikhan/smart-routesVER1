module DmMessage::Operation
  class Index < Trailblazer::Operation
    step :find_room!
    step :authorize!
    step :fetch_messages!

    def find_room!(ctx, params:, **)
      ctx[:dm_room] = DmRoom.find_by(id: params[:dm_room_id])
    end

    def authorize!(ctx, current_user:, dm_room:, **)
      dm_room.sender_id == current_user.id || dm_room.receiver_id == current_user.id
    end

    def fetch_messages!(ctx, dm_room:, **)
      ctx[:model] = dm_room.dm_messages.includes(:user).order(created_at: :asc)
    end
  end
end