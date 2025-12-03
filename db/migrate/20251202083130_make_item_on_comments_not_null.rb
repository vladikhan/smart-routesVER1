class MakeItemOnCommentsNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :comments, :item_type, false
    change_column_null :comments, :item_id, false
  end
end