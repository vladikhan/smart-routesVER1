module Follower::Operation
  class Delete < Trailblazer::Operation
    step :find_model!
    step :delete_with_counters!
    step :remove_notifications!

    def find_model!(ctx, params:, current_user:, **)
      ctx[:model] = Follower.find_by(
        follower_id: current_user.id,
        following_id: params[:id]
      )
    end

    def delete_with_counters!(ctx, model:, **)
      return false unless model

      Follower.transaction do
        follower_id = model.follower_id
        following_id = model.following_id

        model.destroy

        User.decrement_counter(:following_count, follower_id)
        User.decrement_counter(:followers_count, following_id)
      end
      true
    end

    def remove_notifications!(ctx, model:, **)
      # Используем данные из только что удаленной модели
      Notification.where(
        actor_id: model.follower_id,
        user_id: model.following_id,
        notification_type: 'follow'
      ).destroy_all
      true
    end
  end
end