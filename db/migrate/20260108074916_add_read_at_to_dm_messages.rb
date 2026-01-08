class AddReadAtToDmMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :dm_messages, :read_at, :datetime
  end
end
