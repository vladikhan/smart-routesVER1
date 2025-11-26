class AddTagsToRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :routes, :tags, :text
  end
end
