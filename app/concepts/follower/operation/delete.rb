module Follower::Operation
  class Delete < Trailblazer::Operation
    step :find_model!
    step :delete_with_counters!
    step :remove_notifications!

    
    def find_model!(ctx, params:, current_user:, **)
      puts "--- DEBUG DELETE OPERATION ---"
      puts "Params ID: #{params[:id].inspect}"
      puts "Params User ID: #{params[:user_id].inspect}"
      puts "Current User ID: #{current_user&.id}"
      target_id = (params[:user_id] || params[:id]).to_i 
      
      ctx[:model] = Follower.find_by(
        follower_id: current_user.id,
        following_id: target_id
      )
      
      puts "Found Model: #{ctx[:model].inspect}"
      puts "------------------------"
      
      # Если не нашли, давай посмотрим, что вообще есть в таблице
      if ctx[:model].nil?
        puts "All Followers in DB: #{Follower.all.map { |f| "[from: #{f.follower_id} to: #{f.following_id}]" }.join(', ')}"
      end
      
      true # Шаг всегда возвращает true, чтобы мы могли увидеть ошибку на следующем шаге
    end

    def delete_with_counters!(ctx, model:, **)
      return false unless model

      Follower.transaction do
        # Используем destroy!, чтобы если возникнет ошибка, мы её увидели
        if model.destroy
          User.decrement_counter(:following_count, model.follower_id)
          User.decrement_counter(:followers_count, model.following_id)
          puts "DEBUG: Counters decremented successfully"
          true
        else
          puts "DEBUG: Destroy FAILED! Errors: #{model.errors.full_messages}"
          false
        end
      end
    rescue => e
      puts "DEBUG: Exception in delete step: #{e.message}"
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