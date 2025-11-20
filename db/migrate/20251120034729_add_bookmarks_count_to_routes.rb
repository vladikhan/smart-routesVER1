class AddBookmarksCountToRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :routes, :bookmarks_count, :integer, default: 0, null: false
  end
end
