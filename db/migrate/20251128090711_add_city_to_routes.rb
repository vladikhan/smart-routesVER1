class AddCityToRoutes < ActiveRecord::Migration[6.1]
  def change
    add_reference :routes, :city, foreign_key: true, null: true

    reversible do |dir|
      dir.up do
        default_city = City.first

        if default_city
        Route.where(city_id: nil).update_all(city_id: default_city.id)
        else
          puts "No city found, skipping default_city assignment"
        end
        change_column_null :routes, :city_id, false
    end
  end
  end
end