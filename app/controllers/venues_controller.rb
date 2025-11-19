class VenuesController < ApplicationController
	def index
		@venues = Venue.where(status: 'approved')
			.includes(:district, :tags)
			.order(popularity_score: :desc)

		#Filter by query
		if params[:q].present?
			@venues = @venues.where('name LIKE ? OR description LIKE ?',
				"%#{params[:q]}%", "%#{params[:q]}%")
		end

		#Filter by cuisine type
		if params[:cuisine_type].present?
			@venues = @venues.where(cuisine_type: params[:cuisine_type])
		end

		#Filter by price range
		if params[:price_range].present?
			@venues = @venues.where(price_range: params[:price_range])
		end

		@venues = @venues.page(params[:page]).per(12)
	end

	def show
		@venue = Venue.find(params[:id])
		@reviews = @venue.reviews.includes(:user).order(created_at: :desc)
		@routes = @venue.routes.where(is_public: true).limit(4)
	end
end