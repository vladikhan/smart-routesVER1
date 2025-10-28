class CreateDmMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :dm_messages do |t|
      t.references :dm_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false
      t.boolean :is_read, default: false

      t.timestamps
    end

    add_index :dm_messages, :is_read
  end
end
