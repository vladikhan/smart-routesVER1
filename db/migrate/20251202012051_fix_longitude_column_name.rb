class FixLongitudeColumnName < ActiveRecord::Migration[6.1]
  def change
    #Check if wrong column exists
    if column_exists?(:venues, :longtitude)
      rename_column :venues, :longtitude, :longitude
    end

    #Ensure latitude exists with correct spelling
    unless column_exists?(:venues, :latitude)
      add_column :venues, :latitude, :decimal, precision: 10, scale: 6
    end
  end
end
