class AddCoordinatesToVenues < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:venues, :geo_lat)
      add_column :venues, :geo_lat, :decimal, precision: 10, scale: 6
    end

    unless column_exists?(:venues, :geo_lng)
      add_column :venues, :geo_lng, :decimal, precision: 10, scale: 6
    end
  end
end