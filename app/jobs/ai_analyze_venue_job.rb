class AiAnalyzeVenueJob < ApplicationJob
  queue_as :default

  def perform(venue_id)
    venue = Venue.find(venue_id)
    logger.info "🤖 AI начинает анализ заведения: #{venue.name}"
    sleep 10

    logger.info "✅ AI анализ завершен для ID: #{venue_id}"
  end
end
