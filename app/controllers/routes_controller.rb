#encoding: UTF-8
class RoutesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  def index
    @routes = Route.where(is_public: true)
                   .includes(:user, :city)
                   .page(params[:page])
                   .per(12)

    if params[:q].present?
      @routes = @routes.where('name LIKE ? OR description LIKE ?',
                              "%#{params[:q]}%", "%#{params[:q]}%")
    end

    if params[:difficulty].present?
      @routes = @routes.where(difficulty_level: params[:difficulty])
    end

    if params[:duration].present?
      case params[:duration]
      when 'short'
        @routes = @routes.where('estimated_duration <= ?', 180)
      when 'medium'
        @routes = @routes.where('estimated_duration BETWEEN ? AND ?', 181, 360)
      when 'long'
        @routes = @routes.where('estimated_duration > ?', 360)
      end
    end

    if params[:cost].present?
      case params[:cost]
      when 'budget'
        @routes = @routes.where('estimated_cost <= ?', 3000)
      when 'moderate'
        @routes = @routes.where('estimated_cost BETWEEN ? AND ?', 3001, 8000)
      when 'expensive'
        @routes = @routes.where('estimated_cost > ?', 8000)
      end
    end

    case params[:sort]
    when 'popular'
      @routes = @routes.order(view_count: :desc)
    when 'recent'
      @routes = @routes.order(created_at: :desc)
    when 'rating'
      @routes = @routes.order(average_rating: :desc)
    else
      @routes = @routes.order(created_at: :desc)
    end

    @routes = @routes.page(params[:page]).per(15)
  end

  def show
    @route.increment!(:view_count)
    @route_items = @route.route_items.includes(:venue).order(position: :asc)
    @reviews = @route.reviews.includes(:user).order(created_at: :desc).limit(10)
  end

  def new
    @route = current_user.routes.build
    @cities = City.all
    @venues = Venue.all
  end

  def create
    @route = current_user.routes.build(route_params)

    if @route.save
      # Create route items from Google Maps data
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
      :tags
    )
  end

  def authorize_owner!
    unless @route.user == current_user || current_user&.is_admin?
      redirect_to routes_path, alert: 'アクセスが拒否されました。'
    end
  end

  def create_route_items_from_google
    return unless params[:route_items].present?
    
    params[:route_items].each_with_index do |item_params, index|
      # Если есть данные из Google Maps
      if item_params[:venue_name].present? && item_params[:venue_lat].present?
        venue = find_or_create_venue_from_google(item_params)
        
        @route.route_items.create!(
          venue: venue,
          position: index + 1,
          duration_minutes: item_params[:duration_minutes].to_i || 60
        )
      elsif item_params[:venue_id].present?
        # Или используем существующий venue
        @route.route_items.create!(
          venue_id: item_params[:venue_id],
          position: index + 1,
          duration_minutes: item_params[:duration_minutes].to_i || 60
        )
      end
    end
  end

  def find_or_create_venue_from_google(params)
    # Поиск существующего venue по координатам (в радиусе ~10м)
    existing = Venue.where(
      'geo_lat BETWEEN ? AND ? AND geo_lng BETWEEN ? AND ?',
      params[:venue_lat].to_f - 0.0001,
      params[:venue_lat].to_f + 0.0001,
      params[:venue_lng].to_f - 0.0001,
      params[:venue_lng].to_f + 0.0001
    ).first

    return existing if existing

    # Найти ближайший district или использовать первый
    city = City.find_by(id: @route.city_id) || City.first
    district = city.districts.first

    # Создать новый venue
    Venue.create!(
      name: params[:venue_name],
      description: "Added from Google Maps",
      address: params[:venue_address],
      venue_type: 'attraction',
      geo_lat: params[:venue_lat].to_f,
      geo_lng: params[:venue_lng].to_f,
      district: district,
      status: 'approved'
    )
  end

  def update_route_items
    @route.route_items.destroy_all
    create_route_items_from_google
  end
end