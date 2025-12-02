class AddCoordinatesToVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :latitude, :decimal, precision: 10, scale: 6
    add_column :venues, :longtitude, :decimal, precision: 10, scale: 6
  end
end
