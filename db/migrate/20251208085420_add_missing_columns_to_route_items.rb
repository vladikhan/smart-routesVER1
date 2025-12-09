class AddMissingColumnsToRouteItems < ActiveRecord::Migration[6.1]
  def change
    # Add venue_type if it doesn't exist
    unless column_exists?(:route_items, :venue_type)
      add_column :route_items, :venue_type, :string
    end

    # Add venue_name if it doesn't exist (for temporary storage)
    unless column_exists?(:route_items, :venue_name)
      add_column :route_items, :venue_name, :string
    end

    # Add venue_address if it doesn't exist
    unless column_exists?(:route_items, :venue_address)
      add_column :route_items, :venue_address, :string
    end

    # Add notes if it doesn't exist
    unless column_exists?(:route_items, :notes)
      add_column :route_items, :notes, :text
    end

    # Add visit_time if it doesn't exist
    unless column_exists?(:route_items, :visit_time)
      add_column :route_items, :visit_time, :datetime
    end
  end
end
