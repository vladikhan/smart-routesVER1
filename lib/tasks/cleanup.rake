namespace :cleanup do
  desc "Удаляет уведомления старше 30 дней"
  task notifications: :environment do
    # Находим старые записи
    old_records = Notification.where('created_at < ?', 30.days.ago)
    count = old_records.count

    if count > 0
      old_records.delete_all
      puts "🧹 [Cleanup] Удалено старых уведомлений: #{count}"
    else
      puts "✨ [Cleanup] Старых уведомлений не обнаружено. База в порядке!"
    end
  end
end