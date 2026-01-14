class FixNotificationsColumns < ActiveRecord::Migration[6.1]
  def change
    # Переименовываем старые колонки в стандартные, если они назывались иначе
    rename_column :notifications, :entity_id, :notifiable_id if column_exists?(:notifications, :entity_id)
    rename_column :notifications, :entity_type, :notifiable_type if column_exists?(:notifications, :entity_type)

    # Если колонок вообще нет, добавляем их
    return if column_exists?(:notifications, :notifiable_id)

    add_reference :notifications, :notifiable, polymorphic: true, index: true
  end
end
