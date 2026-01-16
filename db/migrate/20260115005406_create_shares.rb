class CreateShares < ActiveRecord::Migration[6.1]
  def change
    create_table :shares do |t|
      t.references :user, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true

      t.timestamps
    end
  end
end
