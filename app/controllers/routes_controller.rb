class RoutesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_route, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]

  def index
    @routes = Route.all

    return unless params[:q].present?

    @routes = @routes.left_outer_joins(:city).where(
      'routes.name ILIKE :q OR cities.name ILIKE :q',
      q: "%#{params[:q]}%"
    ).distinct
  end

  def show
    @route.increment_view_count! if @route.persisted?

    @route_items = @route.route_items
                         .ordered
                         .includes(:item)

    @reviews = @route.reviews.includes(:user).order(created_at: :desc)

    @related_routes = Route.where(city_id: @route.city_id)
                           .where.not(id: @route.id)
                           .where(is_public: true)
                           .limit(3)

    if user_signed_in?
      @current_user_liked = current_user.liked?(@route)
      @current_user_bookmarked = current_user.bookmarked?(@route)
      @current_user_following = current_user.following?(@route.user)
      @user_like = current_user.likes.find_by(likeable: @route)
      @user_bookmark = current_user.bookmarks.find_by(item: @route)
    else
      @current_user_liked = false
      @current_user_bookmarked = false
      @current_user_following = false
    end

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
    puts '!!! REQUEST RECEIVED !!!'
    @route = current_user.routes.build(route_params)

    process_google_maps_items(params[:route][:google_maps_items]) if params[:route][:google_maps_items].present?

    @route.tag_list = params[:route][:tag_list].split(',').map(&:strip) if params[:route][:tag_list].present?

    if @route.save
      redirect_to @route, notice: 'ルートが作成されました'
    else
      @cities = City.all.order(:name)
      @venues = Venue.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @route.update(route_params.except(:images))
      # Если в параметрах есть новые картинки, добавляем их к существующим
      @route.images.attach(route_params[:images]) if route_params[:images].present?
      redirect_to @route, notice: 'ルートを更新しました'
    else
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
    return if @route.user == current_user

    redirect_to routes_path, alert: 'アクセスが拒否されました'
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
      :title,
      :location,
      images: [],
      route_items_attributes: %i[
        id
        venue_id
        name
        description
        order_index
        latitude
        longitude
        _destroy
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

  def delete_image
    @route = Route.find(params[:id])
    image = @route.images.find(params[:image_id])
    image.purge
    redirect_back fallback_location: route_path(@route), notice: '画像が削除されました'
  end
end
