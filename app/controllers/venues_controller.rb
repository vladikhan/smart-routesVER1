
class VenuesController < ApplicationController
  before_action :set_venue, only: [:show]

  def index
    @venues = Venue.approved
                   .includes(:district)
                   .order(popularity_score: :desc)
                   .page(params[:page])
                   .per(12)

    # Фильтры
    @venues = @venues.where(district_id: params[:district_id]) if params[:district_id].present?
    @venues = @venues.where(venue_type: params[:venue_type]) if params[:venue_type].present?
    @venues = @venues.where(cuisine_type: params[:cuisine_type]) if params[:cuisine_type].present?
    @venues = @venues.where('name LIKE ?', "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @venue.increment_view_count
    @reviews = @venue.reviews.includes(:user).order(created_at: :desc).limit(10)
    @routes = @venue.routes.where(is_public: true).limit(5)
  end

  private

  def set_venue
    @venue = Venue.find(params[:id])
  end
end
