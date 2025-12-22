class RemoveNotNullFromRouteItemsItemId < ActiveRecord::Migration[6.1]
  def change
    change_column_null :route_items, :item_id, true
    change_column_null :route_items, :item_type, true
  end
end
