module User::Operation
  class Follow < Trailblazer::Operation
    step :initialize_model!, id: :init_follow_model 
    step :validate_not_self!
    # step Contract::Build(constant: User::Contract::Follow)
    # step Contract::Validate()
    step :persist_and_counters!
    step :notify!

    def initialize_model!(ctx, params:, current_user:, **)
      ctx[:model] = Follower.new(
        follower_id: current_user.id,
        following_id: params[:id]
      )
    end

    def validate_not_self!(ctx, model:, **)
      model.follower_id != model.following_id
    end

    def persist_and_counters!(ctx, model:, **)
      Follower.transaction do
        if model.save
          User.increment_counter(:following_count, model.follower_id)
          User.increment_counter(:followers_count, model.following_id)
          true
        else
          false
        end
      end
    rescue ActiveRecord::RecordNotUnique
      true 
    end

    def notify!(ctx, model:, current_user:, **)
      return true unless model.persisted?

      Activity.create!(
        user: current_user,
        trackable: model,
        key: 'user.follow'
      )

      Notification::Operation::Create.call(params: {
        notification: {
          user_id: model.following_id,
          actor_id: current_user.id,
          action: 'follow',
          notifiable: model
        }
      })
      true
    end
  end
end