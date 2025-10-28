class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { to_table: :users } # 受信者
      t.references :actor, null: false, foreign_key: { to_table: :users } # 実行者
      t.string :notification_type, null: false # follow, like, comment, review
      t.string :entity_type   #Route, Venue, Review
      t.integer :entity_id
      t.boolean :is_read, default: false

      t.timestamps
    end


    add_index :notifications, [:entity_type, :entity_id]
    add_index :notifications, :is_read
  end
end
