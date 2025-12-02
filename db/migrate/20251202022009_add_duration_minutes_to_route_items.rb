class AddDurationMinutesToRouteItems < ActiveRecord::Migration[6.1]
  def change
    add_column :route_items, :duration_minutes, :integer
  end
end
