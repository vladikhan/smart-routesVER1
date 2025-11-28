class AddVenueToRouteItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :route_items, :venue, foreign_key: true
  end
end
