class FixRouteItemsForeignKey < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:route_items, :item_id) && !column_exists?(:route_items, :venue_id)
      rename_column :route_items, :item_id, :venue_id
      puts "✓ Renamed item_id to venue_id"
    elsif column_exists?(:route_items, :venue_id)
      change_column_null :route_items, :venue_id, true
      puts "✓ Made venue_id nullable"
    else
      puts "✓ No changes needed"
    end
  end
end