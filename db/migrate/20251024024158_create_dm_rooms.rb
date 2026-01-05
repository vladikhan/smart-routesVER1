class CreateDmRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :dm_rooms do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at
      t.integer :unread_count_sender, default: 0
      t.integer :unread_count_receiver, default: 0

      t.timestamps
    end

    # Уникальный индекс для предотвращения дублирования комнат
    add_index :dm_rooms, %i[sender_id receiver_id], unique: true
    # Обратный индекс для быстрого поиска
    add_index :dm_rooms, %i[receiver_id sender_id]
  end
end
