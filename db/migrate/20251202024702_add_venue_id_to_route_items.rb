class AddVenueIdToRouteItems < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:route_items, :venue_id)
      add_column :route_items, :venue_id, :bigint 
      add_index  :route_items, :venue_id unless index_exists?(:route_items, :venue_id)
    end
  end
end
