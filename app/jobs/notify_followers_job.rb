class NotifyFollowersJob < ApplicationJob
  queue_as :notifications # Хорошая практика — выделять отдельную очередь для уведомлений

  # retry_on позволяет автоматически повторить задачу, если база была занята
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(route_id)
    route = Route.find_by(id: route_id)

    # Если маршрут уже удалили, пока задача стояла в очереди — просто выходим
    return if route.nil?

    # Проверяем, что маршрут всё еще публичный
    return unless route.is_public?

    Rails.logger.info "🔔 NotifyFollowersJob: Starting for route #{route_id}"

    # Вызываем наш сервис для массовой рассылки
    NotificationService.notify_new_route_from_following(route)

    Rails.logger.info "✅ NotifyFollowersJob: Completed for route #{route_id}"
  rescue StandardError => e
    Rails.logger.error "❌ NotifyFollowersJob failed for route #{route_id}: #{e.message}"
    raise e # Пробрасываем ошибку дальше, чтобы ActiveJob зафиксировал провал
  end
end
