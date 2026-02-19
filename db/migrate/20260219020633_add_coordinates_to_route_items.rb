class AddCoordinatesToRouteItems < ActiveRecord::Migration[6.1]
  def change
    add_column :route_items, :latitude, :float
    add_column :route_items, :longitude, :float
  end
end
