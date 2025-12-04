class RemoveCommentableColumnsFromComments < ActiveRecord::Migration[6.1]
  def change
    remove_column :comments, :commentable_type, :string
    remove_column :comments, :commentable_id, :integer

  end
end
