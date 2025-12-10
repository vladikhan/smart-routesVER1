class AddCoordinatesToRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :routes, :geo_lat, :decimal, precision: 10, scale: 6
    add_column :routes, :geo_lng, :decimal, precision: 10, scale: 6
  end
end
