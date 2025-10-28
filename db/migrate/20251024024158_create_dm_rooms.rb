class CreateDmRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :dm_rooms do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at

      t.timestamps
    end

    

    add_index :dm_rooms, [:sender_id, :receiver_id], unique: true
  end
end
