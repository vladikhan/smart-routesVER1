class VenuesController < ApplicationController
  before_action :set_venue, only: [:show]

  def index
    @venues = Venue.approved
                   .includes(:district)
                   .order(popularity_score: :desc)
                   .page(params[:page])
                   .per(12)

    @venues = @venues.where(district_id: params[:district_id]) if params[:district_id].present?
    @venues = @venues.where(venue_type: params[:venue_type]) if params[:venue_type].present?
    @venues = @venues.where(cuisine_type: params[:cuisine_type]) if params[:cuisine_type].present?
    @venues = @venues.where('name LIKE ?', "%#{params[:q]}%") if params[:q].present?
  end

  def show
    @venue.increment_view_count

    @venue = Venue.find(params[:id])
    AiAnalyzeVenueJob.perform_later(@venue.id)

    @route = @venue.routes.joins(:route_items)
                   .order('route_items.position ASC')
                   .first

    # Если нет маршрута → пустой массив
    @route_items = @route ? @route.route_items.includes(:venue, :item) : []

    @reviews = @route ? @route.reviews.includes(:user).order(created_at: :desc).limit(10) : []

    @routes = @venue.routes.where(is_public: true).limit(5)
    @reviews = @venue.reviews
  end

  def update
    @venue = Venue.find(params[:id])

    if params[:venue][:photos].present?
      @venue.photos.attach(params[:venue][:photos])

      redirect_to venue_path(@venue), notice: '写真をアップロードしました！'
    elsif @venue.update(venue_params)
      redirect_to venue_path(@venue), notice: '更新しました'
    else
      puts @venue.errors.full_messages
      render :edit
    end
  end

  def delete_photo
    @venue = Venue.find(params[:id])
    photo = @venue.photos.find_by(id: params[:photo_id])

    if photo
      photo.purge
      flash[:notice] = '写真を削除しました'
    else
      flash[:alert] = '写真が見つかりませんでした'
    end

    redirect_back(fallback_location: venue_path(@venue))
  end

  private

  def set_venue
    @venue = Venue.find(params[:id])
  end

  def venue_params
    params.require(:venue).permit(:name, :description, :address, :venue_type, :district_id, photos: [])
  end
end
