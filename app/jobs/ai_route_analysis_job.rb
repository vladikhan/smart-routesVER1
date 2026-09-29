class AiRouteAnalysisJob < ApplicationJob
  queue_as :default

  def perform(venue_id)
    venue = Venue.find(venue_id)
    puts "--- Starting AI analysis for place #{venue.name} --- "
    sleep 5
    puts '--- Completed! ---'
  end
end
