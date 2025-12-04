class EnsureTagsIsString < ActiveRecord::Migration[6.1]
  def up
    # Remove any existing tags column and recreate as string
    if column_exists?(:routes, :tags)
      remove_column :routes, :tags
    end
    add_column :routes, :tags, :string
  end

  def down
    remove_column :routes, :tags if column_exists?(:routes, :tags)
  end
end
