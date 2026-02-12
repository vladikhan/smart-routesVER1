module Like::Operation
  class Create < Trailblazer::Operation
    step Model(Like, :new)
    step Contract.Build(constant: Like::Contract::Create)

    step Contract.Validate
    step :persist_with_counters!
    step :create_activity!
    step :notify!

    def persist_with_counters!(ctx, model:, **)
      Like.transaction do
        return false unless ctx['contract.default'].save

        klass = model.likeable_type.constantize
        if klass.column_names.include?('likes_count')
          klass.increment_counter(:likes_count, model.likeable_id)
        end
      end
      true
    rescue ActiveRecord::RecordNotUnique
      ctx[:error] = 'Already Liked'
      p "EXCEPTION IN OPERATION: #{e.message}"
      false
    end

    def notify!(ctx, model:, **)
      target_user_id = model.likeable&.try(:user_id)
      return true if target_user_id.nil? || target_user_id == model.user_id

      Notification::Operation::Create.call(
        params: {
          notification: {
            user_id: model.likeable.user_id,
            actor_id: model.user_id,
            notification_type: 'like',
            notifiable: model
          }
        }
      )
      true
    end

    def create_activity!(ctx, model:, **)
      Activity.create!(user: model.user, trackable: model, key: 'like.create')
      true
    rescue => e
      Rails.logger.error("Activity failed: #{e.message}")
      true
    end
  end
end
