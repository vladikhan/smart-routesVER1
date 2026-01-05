class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { to_table: :users } # 受信者
      t.references :actor, null: false, foreign_key: { to_table: :users } # 実行者

      t.references :notifiable, polymorphic: true, null: false
      t.string :notification_type, null: false, default: 0 # follow, like, comment, review
      t.string :entity_type # Route, Venue, Review
      t.integer :entity_id
      t.boolean :is_read, default: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, %i[user_id is_read]
    add_index :notifications, %i[notifiable_type notifiable_id]
    add_index :notifications, %i[user_id created_at]
  end
end
