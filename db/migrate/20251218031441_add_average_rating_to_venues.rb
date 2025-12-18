class AddAverageRatingToVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :average_rating, :float, default: 0
  end
end
