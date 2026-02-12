module DmMessage::Operation
  class Index < Trailblazer::Operation
    step :find_room!
    step :authorize!
    step :fetch_messages!
    step :mark_as_read!

    def find_room!(ctx, params: {}, **)
      # room_id = params&.[](:dm_room_id)
      ctx[:dm_room] = DmRoom.find_by(id: params[:dm_room_id])
      ctx[:dm_room].present?
    end

    def authorize!(ctx, current_user:, dm_room:, **)
      # Короткая и понятная проверка участия
      dm_room.participant?(current_user)
    end

    def fetch_messages!(ctx, dm_room:, **)
      ctx[:model] = dm_room.dm_messages.includes(:user).order(created_at: :asc)
    end

    def mark_as_read!(ctx, dm_room:, current_user:, **)
      dm_room.mark_all_as_read_for(current_user)  
      true
    end
  end
end