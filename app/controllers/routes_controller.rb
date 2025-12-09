class RoutesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  def index
    @routes = Route.where(is_public: true)
                   .includes(:user, :city)
                   .order(created_at: :desc)

    if params[:q].present?
      @routes = @routes.where('name LIKE ? OR description LIKE ?',
                              "%#{params[:q]}%", "%#{params[:q]}%")
    end

    if params[:difficulty].present?
      @routes = @routes.where(difficulty_level: params[:difficulty])
    end

    @routes = @routes.page(params[:page]).per(15)
  end

  def show
    @route.increment!(:view_count)
    
    begin
      @route_items = @route.route_items.includes(:venue).order(position: :asc)
    rescue ActiveRecord::ConfigurationError
      @route_items = @route.route_items.order(position: :asc)
    end
    
    @reviews = @route.reviews.includes(:user).order(created_at: :desc).limit(10) rescue []
  end

  def new
    @route = current_user.routes.build
    @cities = City.all
    @venues = Venue.all
  end

  def create
    if params[:route][:tag_ids].present?
      params[:route][:tag_ids] = params[:route][:tag_ids].reject(&:blank?)
    end

    @route = current_user.routes.build(route_params)

    if @route.save
      create_route_items_from_google if params[:route_items].present?
      redirect_to @route, notice: '✓ ルートが正常に作成されました。'
    else
      @cities = City.all
      @venues = Venue.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_owner!
    @cities = City.all
    @venues = Venue.all
  end

  def update
    authorize_owner!

    if params[:route][:tag_ids].present?
      params[:route][:tag_ids] = params[:route][:tag_ids].reject(&:blank?)
    end

    if @route.update(route_params)
      update_route_items if params[:route_items].present?
      redirect_to @route, notice: '✓ ルートが更新されました。'
    else
      @cities = City.all
      @venues = Venue.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_owner!
    @route.destroy
    redirect_to routes_path, notice: 'ルートが削除されました。'
  end

  private

  def set_route
    @route = Route.find(params[:id])
  end

  def route_params
    params.require(:route).permit(
      :name, 
      :description, 
      :estimated_duration,
      :estimated_cost, 
      :difficulty_level, 
      :is_public,
      :city_id,
      tag_ids: []
    )
  end

  def authorize_owner!
    unless @route.user == current_user || current_user&.is_admin?
      redirect_to routes_path, alert: 'アクセスが拒否されました。'
    end
  end

  def create_route_items_from_google
    return unless params[:route_items].present?
    
    success_count = 0
    
    params[:route_items].each_with_index do |item_params, index|
      next if item_params[:venue_name].blank?
      next if item_params[:venue_lat].blank? || item_params[:venue_lng].blank?
      
      begin
        venue = find_or_create_venue_from_google(item_params)
        next unless venue
        
        route_item = @route.route_items.create!(
          venue: venue,
          position: index + 1,
          duration_minutes: item_params[:duration_minutes].to_i || 60,
          venue_name: item_params[:venue_name],
          venue_address: item_params[:venue_address] || '',
          item_type: 'venue'
        )
        
        success_count += 1
      rescue => e
        Rails.logger.error "Error creating route item: #{e.message}"
        next
      end
    end
    
    success_count > 0
  end

  def find_or_create_venue_from_google(params)
    lat = params[:venue_lat].to_f
    lng = params[:venue_lng].to_f
    
    return nil if lat == 0.0 || lng == 0.0
    
    existing = Venue.where(
      'geo_lat BETWEEN ? AND ? AND geo_lng BETWEEN ? AND ?',
      lat - 0.0001,
      lat + 0.0001,
      lng - 0.0001,
      lng + 0.0001
    ).first

    return existing if existing

    city = City.find_by(id: @route.city_id) || City.first
    district = city&.districts&.first || District.first

    return nil unless district

    Venue.create!(
      name: params[:venue_name],
      description: "Added from Google Maps",
      address: params[:venue_address] || "",
      venue_type: 'attraction',
      geo_lat: lat,
      geo_lng: lng,
      district: district,
      status: 'approved'
    )
  rescue => e
    Rails.logger.error "Error creating venue: #{e.message}"
    nil
  end

  def update_route_items
    @route.route_items.destroy_all
    create_route_items_from_google
  end
end
