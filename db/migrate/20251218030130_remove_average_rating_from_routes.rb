class RemoveAverageRatingFromRoutes < ActiveRecord::Migration[6.1]
  def change
    remove_column :routes, :average_rating, :decimal
  end
end
