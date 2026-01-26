class AddBookmarksCountToVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :bookmarks_count, :integer, default: 0, null: false
  end
end
