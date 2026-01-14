class CreateFollowers < ActiveRecord::Migration[6.1]
  def change
    create_table :followers do |t|
      t.integer :follower_id, null: false # フォローする人
      t.integer :following_id, null: false # フォローされる人
      t.string :status, default: 'pending' # 'pending', 'accepted'

      t.timestamps
    end

    add_foreign_key :followers, :users, column: :follower_id
    add_foreign_key :followers, :users, column: :following_id

    add_index :followers, :follower_id
    add_index :followers, :following_id
    add_index :followers, %i[follower_id following_id], unique: true
  end
end
