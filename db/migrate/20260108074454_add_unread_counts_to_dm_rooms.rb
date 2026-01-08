class AddUnreadCountsToDmRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :dm_rooms, :unread_count_sender, :integer
    add_column :dm_rooms, :unread_count_receiver, :integer
  end
end
