class RevertNotificationColumnsToEntity < ActiveRecord::Migration[6.1]
  def change
    rename_column :notifications, :notifiable_type, :entity_type
    rename_column :notifications, :notifiable_id, :entity_id

    remove_index :notifications, [:notifiable_type, :notifiable_id], if_exists: true
    add_index :notifications, [:entity_type, :entity_id], if_not_exists: true
  end
end
