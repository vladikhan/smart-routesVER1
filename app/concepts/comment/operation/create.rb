module Comment::Operation
  class Create < Trailblazer::Operation
    step Model(Comment, :new)
    step Contract::Build(constant: Comment::Contract::Create)
    step Contract::Validate()
    step Contract::Persist()
    step :log_activity!
    step :notify!

    def log_activity!(ctx, model: ,current_user:, **)
      Activity.create!(
        user: current_user,
        trackable: model,
        key: 'comment.create'
      )
      true
    rescue  => e 
      Rails.logger.error "アクティビティログの失敗: #{e.message}"
      true
    end


    def notify!(ctx, model:, current_user:, **)
      target_user_id = model.commentable.try(:user_id)
      return true if target_user_id == current_user.id

      if model.parent_id.present?
        NotificationService.notify_reply_added(model)
      else
        NotificationService.notify_comment_added(model)
      end
      true
    end
  end
end