module Notification::Operation
  class Create < Trailblazer::Operation
    step :should_notify?
    step :setup_params!
    step :persist!

    def should_notify?(ctx, params:, **)
      p = params[:notification]
      
      # Senior Tip: Не уведомляем пользователя о его собственных действиях
      return false if p[:user_id].to_i == p[:actor_id].to_i
      
      # Проверяем наличие обязательных данных
      p[:user_id].present? && p[:notifiable].present?
    end

    def setup_params!(ctx, params:, **)
      p = params[:notification]
      # Используем .new, но данные берем из params динамически
      ctx[:model] = Notification.new(
        user_id:           p[:user_id],
        actor_id:          p[:actor_id],
        notification_type: p[:action] || p[:notification_type],
        notifiable:        p[:notifiable], # Rails сам поймет type и id
        is_read:           false
      )
    end

    def persist!(ctx, model:, **)
      model.save
    end

    def broadcast!(ctx, model:, **)
      presenter = NotificationPresenter.new(model)
      
      ActionCable.server.broadcast(
        "notification_#{model.user_id}",
        {
          unread_count: model.user.notifications.unread.count,
          notification: {
            id: model.id,
            message: presenter.message,
            icon: presenter.icon,
            url: presenter.target_url,
            created_at: model.created_at,
            actor: { username: model.actor&.username }
          }
        }
      )
    end
  end
end