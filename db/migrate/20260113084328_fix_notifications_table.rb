class FixNotificationsTable < ActiveRecord::Migration[6.1]
  def change
    # 1. Добавляем полиморфную связь (notifiable_id и notifiable_type)
    # Это позволит уведомлению "знать", к чему оно относится (сообщению, лайку и т.д.)
    unless column_exists?(:notifications, :notifiable_id)
      add_reference :notifications, :notifiable, polymorphic: true, index: true
    end

    # 2. Добавляем колонку для текста уведомления, если её нет
    add_column :notifications, :message, :text unless column_exists?(:notifications, :message)

    # 3. Добавляем тип уведомления, если он отсутствует
    return if column_exists?(:notifications, :notification_type)

    add_column :notifications, :notification_type, :string
  end
end
