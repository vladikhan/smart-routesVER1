class AddOrderIndexToRouteItems < ActiveRecord::Migration[6.1]
  def change
    add_column :route_items, :order_index, :integer
  end
end
