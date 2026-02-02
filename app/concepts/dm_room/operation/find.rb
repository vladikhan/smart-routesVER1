module DmRoom::Operation
  class FindOrCreate < Trailblazer::Operation
    step :find_existing!
    step :create_room!, Output(:succes) => End(:success)

    def find_existing!(ctx, params:, **)
      u1_id, u2_id = [params[user1_id].to_i, params[:user2_id].to_i].sort

      ctx[:model] = DmRoom.find_by(sender_id: u1_id, receiver_id: u2_id)
      ctx[:model].present?
    end

    def create_room!(ctx, params:, **)
     u1_id, u2_id = [params[:user1_id].to_i, params[:user2_id].to_i].sort
      ctx[:model] = DmRoom.create!(sender_id: u1_id, receiver_id: u2_id)
    rescue ActiveRecord::RecordNotUnique
      # На случай race condition, если кто-то создал комнату секунду назад
      ctx[:model] = DmRoom.find_by(sender_id: u1_id, receiver_id: u2_id)
    end
  end
end