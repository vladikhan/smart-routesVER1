class AddAverageRatingToRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :routes, :average_rating, :float, default: 0
  end
end
