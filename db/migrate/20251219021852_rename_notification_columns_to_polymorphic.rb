class RenameNotificationColumnsToPolymorphic < ActiveRecord::Migration[6.1]
  def change
    # Переименовываем старые колонки под стандарт Rails
    rename_column :notifications, :entity_type, :notifiable_type
    rename_column :notifications, :entity_id, :notifiable_id
    
    # Рекомендуется добавить индекс для скорости
    add_index :notifications, [:notifiable_type, :notifiable_id], if_not_exists: true
  end
end
