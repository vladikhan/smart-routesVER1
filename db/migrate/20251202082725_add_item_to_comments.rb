class AddItemToComments < ActiveRecord::Migration[6.1]
  def change
    add_reference :comments, :item, polymorphic: true, null: true
  end
end
