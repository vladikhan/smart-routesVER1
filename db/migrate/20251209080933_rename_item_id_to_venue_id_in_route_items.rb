
class RenameItemIdToVenueIdInRouteItems < ActiveRecord::Migration[6.1]

  def change

    # Only rename if item_id exists and venue_id doesn't

    if column_exists?(:route_items, :item_id) && !column_exists?(:route_items, :venue_id)

      rename_column :route_items, :item_id, :venue_id

      puts "✓ Renamed item_id to venue_id"

    elsif column_exists?(:route_items, :venue_id)

      puts "✓ venue_id already exists, no change needed"

    else

      puts "⚠ Neither item_id nor venue_id found"

    end

  end

end

