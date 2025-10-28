class CreateRouteItems < ActiveRecord::Migration[6.1]
  def change
    create_table :route_items do |t|
      t.references :route, null: false, foreign_key: true
      t.string :item_type, null: false  # 'Venue'
      t.integer :item_id, null: false #venue_id
      t.integer :position, null: false
      t.text :notes

      t.timestamps
    end

    add_index :route_items, [:route_id, :position], unique: true
    add_index :route_items, [:item_type, :item_id]
  end
end
