module MapsHelper
  def google_maps_api_key
      ENV['GOOGLE_MAPS_API_KEY']
  end

  def google_maps_script_tag
    javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=#{google_maps_api_key}&libraries=places&language=ja", defer: true
  end
end