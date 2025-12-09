class AddNotifiableToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_reference :notifications, :notifiable, polymorphic: true, index: true
  end
end
