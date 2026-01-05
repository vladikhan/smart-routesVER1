class CreateDmMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :dm_messages do |t|
      t.references :dm_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message
      t.boolean :is_read, default: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :dm_messages, :is_read
    add_index :dm_messages, %i[dm_room_id create_at]
  end
end
