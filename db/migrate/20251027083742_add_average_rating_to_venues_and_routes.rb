class AddAverageRatingToVenuesAndRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :average_rating, :float, default: 0.0
    add_column :routes, :average_rating, :float, default: 0.0
  end
end