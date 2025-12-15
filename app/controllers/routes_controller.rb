class RoutesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @routes = Route.where(is_public: true)
                   .includes(:user, :city)
                   .order(created_at: :desc)
  end

  def show
    @route.increment_view_count! if @route.persisted?
    
    @route_items = @route.route_items
                         .includes(:venue)
                         .order(:order_index)
    
    @map_items = @route_items.map do |item|
      {
        id: item.id,
        name: item.venue&.name || item.name,
        latitude: item.venue&.latitude || item.latitude,
        longitude: item.venue&.longitude || item.longitude,
        address: item.venue&.address,
        order_index: item.order_index
      }
    end.compact
  end

  def new
    @route = Route.new
    @cities = City.all.order(:name)
    @venues = Venue.all.order(:name)
    @route.route_items.build
  end

  def edit
    @cities = City.all.order(:name)
    @venues = Venue.all.order(:name)
  end

  def create
    @route = current_user.routes.build(route_params)
    
    if params[:route][:google_maps_items].present?
      process_google_maps_items(params[:route][:google_maps_items])
    end
    
    if params[:route][:tag_list].present?
      @route.tag_list = params[:route][:tag_list].split(',').map(&:strip)
    end

    if @route.save
      redirect_to @route, notice: 'ルートが作成されました'
    else
      @cities = City.all.order(:name)
      @venues = Venue.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:route][:tag_list].present?
      @route.tag_list = params[:route][:tag_list].split(',').map(&:strip)
    end

    if @route.update(route_params)
      redirect_to @route, notice: 'ルートが更新されました'
    else
      @cities = City.all.order(:name)
      @venues = Venue.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @route.destroy
    redirect_to routes_path, notice: 'ルートが削除されました'
  end

  private

  def set_route
    @route = Route.find(params[:id])
  end

  def authorize_owner!
    unless @route.user == current_user
      redirect_to routes_path, alert: 'アクセスが拒否されました'
    end
  end

  def route_params
    params.require(:route).permit(
      :name,
      :description,
      :city_id,
      :estimated_cost,
      :estimated_duration,
      :is_public,
      :start_date,
      :end_date,
      route_items_attributes: [
        :id,
        :venue_id,
        :name,
        :description,
        :order_index,
        :latitude,
        :longitude,
        :_destroy
      ]
    )
  end

  def process_google_maps_items(items_json)
    items = JSON.parse(items_json)
    items.each_with_index do |item, index|
      @route.route_items.build(
        name: item['name'],
        latitude: item['latitude'],
        longitude: item['longitude'],
        order_index: index,
        description: item['address']
      )
    end
  rescue JSON::ParserError
    # Игнорируем ошибки парсинга
  end
end
