class FixRouteItemsItemType < ActiveRecord::Migration[6.1]
  def change
    # Option 1: Make item_type nullable (recommended)
    change_column_null :route_items, :item_type, true
    
    # Option 2: Set a default value
    change_column_default :route_items, :item_type, from: nil, to: 'venue'
  end
end
