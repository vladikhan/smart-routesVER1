class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.string :reviewable_type, null: false #'Venue', 'Route'
      t.integer :reviewable_id, null: false
      t.text :text, null: false
      t.decimal :total_score, precision: 3, scale: 2, null: false
      t.boolean :is_flagged, default: false
      t.datetime :flagged_at
      t.integer :flagged_by
      t.boolean :is_hidden_by_admin, default: false
      t.integer :likes_count, default: 0

      t.timestamps
    end

    add_index :reviews, [:reviewable_type, :reviewable_id]
    add_index :reviews, :total_score
    add_index :reviews, :is_flagged
  end
end
