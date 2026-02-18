module Follower::Operation
  class Create < Trailblazer::Operation
    step :authorize!
    step Model(Follower, :new), id: :create_model
    step :setup_params!
    step Contract::Build(constant: Follower::Contract::Create)
    step Contract::Validate()
    step :persist_with_counters!
    step :notify!

    def authorize!(ctx, current_user:, **)
      current_user.present? 
    end

    def setup_params!(ctx, current_user:, params:, **)
      ctx[:params] = { follower_id: current_user.id,
                       following_id: params[:following_id]}
    end

    def persist_with_counters!(ctx, model:, **)
    Follower.transaction do
      if ctx["contract.default"].save
        User.increment_counter(:following_count, model.follower_id)
        User.increment_counter(:followers_count, model.following_id)
        true
      else
        raise ActiveRecord::Rollback
        false
      end
    end
  rescue ActiveRecord::RecordNotUnique
    ctx[:error] = "Already followed"
    false
  end

  def notify!(ctx, model:, **)
    result = Notification::Operation::Create.call(params: {
      notification: {
        user_id: model.following_id,
        actor_id: model.follower_id,
        notification_type: 'follow_request',
        notifiable: model
      }
    })
    true
  end
  end
end