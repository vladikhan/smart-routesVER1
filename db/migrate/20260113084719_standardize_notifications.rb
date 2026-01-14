class StandardizeNotifications < ActiveRecord::Migration[6.1]
  def change
    # 1. Безопасно переименовываем entity_type -> notifiable_type
    if column_exists?(:notifications, :entity_type) && !column_exists?(:notifications, :notifiable_type)
      rename_column :notifications, :entity_type, :notifiable_type
    elsif !column_exists?(:notifications, :notifiable_type)
      add_column :notifications, :notifiable_type, :string
    end

    # 2. Безопасно переименовываем entity_id -> notifiable_id
    if column_exists?(:notifications, :entity_id) && !column_exists?(:notifications, :notifiable_id)
      rename_column :notifications, :entity_id, :notifiable_id
    elsif !column_exists?(:notifications, :notifiable_id)
      add_column :notifications, :notifiable_id, :bigint
    end

    # 3. Добавляем колонку message, если её точно нет
    add_column :notifications, :message, :text unless column_exists?(:notifications, :message)

    # 4. Добавляем индекс для полиморфной связи (ускоряет выборку уведомлений)
    return if index_exists?(:notifications, %i[notifiable_type notifiable_id])

    add_index :notifications, %i[notifiable_type notifiable_id]
  end
end
