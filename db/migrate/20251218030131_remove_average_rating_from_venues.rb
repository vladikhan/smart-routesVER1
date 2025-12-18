class RemoveAverageRatingFromVenues < ActiveRecord::Migration[6.1]
  def change
    remove_column :venues, :average_rating, :decimal
  end
end
