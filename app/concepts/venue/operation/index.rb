class Venue::Operation::Index < Trailblazer::Operation
  step :model!

  def model!(ctx, params:, **)
    
    venues = ::Venue.approved.includes(:district)
    
    # Фильтрация
    venues = venues.where(district_id: params[:district_id]) if params[:district_id].present?
    venues = venues.where(venue_type: params[:venue_type])   if params[:venue_type].present?
    
    
    if params[:q].present?
      venues = venues.where('name ILIKE :q OR description ILIKE :q', q: "%#{params[:q]}%")
    end

    ctx[:model] = venues.order(popularity_score: :desc).page(params[:page]).per(12)
  end
end