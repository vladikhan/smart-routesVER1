class ChangeItemTypeDefaultInRouteItems < ActiveRecord::Migration[6.1]
  def change
    change_column_default :route_items, :item_type, from: "venue", to: "Venue"
  end
end
