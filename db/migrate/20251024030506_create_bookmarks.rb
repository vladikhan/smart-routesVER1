class CreateBookmarks < ActiveRecord::Migration[6.1]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :item_type, null: false # 'Route', 'Venue'
      t.integer :item_id, null: false
      t.string :collection_name
      t.text :notes

      t.timestamps
    end

    add_index :bookmarks, %i[item_type item_id]
    add_index :bookmarks, %i[user_id item_type item_id], unique: true, name: 'index_bookmarks_unique'
  end
end
