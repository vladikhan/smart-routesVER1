class ForceAddPolymorphicToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :entity_type, :string unless column_exists?(:notifications, :entity_type)

    add_column :notifications, :entity_id, :integer unless column_exists?(:notifications, :entity_id)

    return if index_exists?(:notifications, %i[entity_type entity_id])

    add_index :notifications, %i[entity_type entity_id]
  end
end
