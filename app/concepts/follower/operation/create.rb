module Follower::Operation
  class Create < Trailblazer::Operation
    step Model(Follower, :new), id: :create_model
    step :setup_params!
    step Contract::Build(constant: Follower::Contract::Create)
    step Contract::Validate()
    step :persist_with_counters!
    step :notify!

    def setup_params!(ctx, params:, **)
      ctx[:params] = { follower: params}
    end

    def persist_with_counters!(ctx, model:, **)
  
  Follower.transaction do
    if ctx["contract.default"].save
      User.increment_counter(:following_count, model.follower_id)
      User.increment_counter(:followers_count, model.following_id)
    else
      Rails.logger.debug "!!! Contract Validation Failed: #{ctx["contract.default"].errors.full_messages}"
      raise ActiveRecord::Rollback # Откатываем транзакцию, если сейв не удался
    end
  end
  
  success # Возвращаем результат выполнения шага (true или false)
rescue ActiveRecord::RecordNotUnique => e
  Rails.logger.debug "!!! Already followed: #{e.message}"
  ctx[:error] = "Already followed"
  false
    end

    def notify!(ctx, model:, **)
      Notification::Operation::Create.call(params: {
        notification: {
          user_id: model.following_id,
          actor_id: model.follower_id,
          action: 'follow',
          notifiable: model
        }
      })
      true
    end
  end
end