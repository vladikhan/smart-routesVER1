class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :commentable_type, null: false #'Review', ' Route'
      t.integer :commentable_id, null: false
      t.text :text, null: false
      t.integer :parent_id  # 返信コメント用
      t.boolean :is_flagged, default: false
      t.boolean :is_hidden_by_admin, default: false

      t.timestamps
    end

    add_index :comments, [:commentable_type, :commentable_id]
    add_index :comments, :parent_id
  end
end
