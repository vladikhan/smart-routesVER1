class AddReadAtToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :read_at, :datetime
  end
end
