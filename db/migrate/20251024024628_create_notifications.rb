class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }, index: true # 受信者
      t.references :actor, null: false, foreign_key: { to_table: :users }, index: true # 実行者

      t.references :notifiable, polymorphic: true, null: false, index: true
      t.string :notification_type, null: false, default: 0 # follow, like, comment, review
      t.string :entity_type # Route, Venue, Review
      t.integer :entity_id
      t.boolean :is_read, default: false, null: false
      t.datetime :read_at

      t.json :extra_data

      t.timestamps
    end

    add_index :notifications, %i[user_id is_read], name: 'index_notifications_on_user_and_read'
    add_index :notifications, %i[notifiable_type notifiable_id], name: 'index_notifications_on_user_and_type'
    add_index :notifications, %i[user_id created_at]
  end
end
