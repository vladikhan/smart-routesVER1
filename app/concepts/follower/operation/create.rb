module Follower::Operation
  class Create < Trailblazer::Operation
    step Model(Follower, :new), id: :create_model
    step :setup_params!
    step Contract::Build(constant: Follower::Contract::Create)
    step Contract::Validate()
    step :persist_with_counters!
    step :notify!

    def setup_params!(ctx, params:, **)
      ctx[:params] = { follower: params }
    end

    def persist_with_counters!(ctx, model:, **)
      Follower.transaction do
        if ctx["contract.default"].save
          User.increment_counter(:following_count, model.follower_id)
          User.increment_counter(:followers_count, model.following_id)
          true 
        else
          Rails.logger.debug "!!! Validation Failed: #{ctx["contract.default"].errors.full_messages}"
          raise ActiveRecord::Rollback
          false
        end
      end # Конец транзакции
    rescue ActiveRecord::RecordNotUnique
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