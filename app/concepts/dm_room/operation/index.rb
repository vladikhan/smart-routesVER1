module DmRoom::Operation
  class Index < Trailblazer:: Operation
    step :fetch_rooms!
    step :set_active_room!
    step :mark_all_as_read!
    step :fetch_messages!

    def fetch_rooms!(ctx, current_user:, **)
      ctx[:dm_rooms] = DmRoom.for_user_with_preloads(current_user)
                             .order(last_message_at: :desc)
    end

    def set_active_room!(ctx, params:, dm_rooms:, **)
      ctx[:active_room] = params[:id] ? DmRoom.find_by(id: params[:id]) : dm_rooms.first
      ctx[:active_room].present?
    end

    def mark_all_as_read!(ctx, active_room:, current_user:, **)
      active_room.mark_all_as_read_for(current_user)
      true
    end

    def fetch_messages!(ctx, active_room:, **)
      ctx[:messages] = active_room.dm_messages
                                  .includes(:user)
                                  .with_attached_image
                                  .order(created_at: :asc)
                                  .limit(100)
    end
  end
end