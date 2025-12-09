class RemoveNotifiableFromNotifications < ActiveRecord::Migration[6.1]
  def change
    remove_column :notifications, :notifiable_type, :string
    remove_column :notifications, :notifiable_id, :integer
  end
end
