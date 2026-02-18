module Follower::Operation
  class Delete < Trailblazer::Operation
    step :find_model!
    step :delete_with_counters!
    step :remove_notifications!

    
    def find_model!(ctx, params:, current_user:, **)
      
      target_id = (params[:user_id] || params[:id]).to_i 
      
      ctx[:model] = Follower.find_by(
        follower_id: current_user.id,
        following_id: target_id
      )
     
      true # Шаг всегда возвращает true, чтобы мы могли увидеть ошибку на следующем шаге
    end

    def delete_with_counters!(ctx, model:, **)
      return false unless model

      Follower.transaction do
        # Используем destroy!, чтобы если возникнет ошибка, мы её увидели
        if model.destroy
          User.decrement_counter(:following_count, model.follower_id)
          User.decrement_counter(:followers_count, model.following_id)
          
          true
        else
          false
        end
      end
    rescue => e
      false
    end

    def remove_notifications!(ctx, model:, **)
  Notification.where(
    actor_id: model.follower_id,
    user_id: model.following_id,
    notification_type: 'follow'
  ).destroy_all
  true
end
  end
end