class CreateRoutes < ActiveRecord::Migration[6.1]
  def change
    create_table :routes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :is_public, default: true
      t.integer :view_count, default: 0
      t.integer :download_count, default: 0
      t.integer :completion_count, default: 0
      t.float :popularity_score, default: 0.0
      t.boolean :is_featured, default: false
      t.integer :featured_order
      t.integer :estimated_duration # 分単位

      t.integer :estimated_cost # 円単位
      t.string :difficulty_level
      t.boolean :is_deleted, default: false
      t.integer :likes_count, default: 0
      t.integer :reviews_count, default: 0

      t.timestamps
    end

    add_index :routes, :is_public
    add_index :routes, :is_featured
    add_index :routes, :popularity_score
    add_index :routes, :is_deleted
  end
end
