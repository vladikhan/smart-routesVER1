
class RoutesController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]

  before_action :set_route, only: [:show, :edit, :update, :destroy]

  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  

  def index

    @routes = Route.where(is_public: true)
                   .includes(:user, :city, :tags)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(20)

  end

  

  def show

    @route_items = @route.route_items.includes(:venue).order(position: :asc)

    @map_items = @route_items.map do |item|

      {

        name: item.venue_name || item.venue&.name,

        lat: item.venue_lat || item.venue&.geo_lat,

        lng: item.venue_lng || item.venue&.geo_lng,

        address: item.venue_address || item.venue&.address

      }

    end.compact

    

    @route.increment_view_count

  end

  

  def new

    @route = Route.new

    @cities = City.all

    @venues = Venue.where(status: 'approved').limit(100)

  end

  

  def create

    @route = current_user.routes.build(route_params)

    

    if @route.save

      # Handle route items if present

      if params[:route_items].present?

        params[:route_items].each_with_index do |item_params, index|

          @route.route_items.create(

            venue_name: item_params[:venue_name],

            venue_address: item_params[:venue_address],

            venue_lat: item_params[:venue_lat],

            venue_lng: item_params[:venue_lng],

            duration_minutes: item_params[:duration_minutes],

            position: index + 1

          )

        end

      end

      

      redirect_to @route, notice: 'ルートを作成しました'

    else

      @cities = City.all

      @venues = Venue.where(status: 'approved').limit(100)

      render :new, status: :unprocessable_entity

    end

  end

  

  def edit

    @cities = City.all

    @venues = Venue.where(status: 'approved').limit(100)

  end

  

  def update

    if @route.update(route_params)

      redirect_to @route, notice: 'ルートを更新しました'

    else

      @cities = City.all

      @venues = Venue.where(status: 'approved').limit(100)

      render :edit, status: :unprocessable_entity

    end

  end

  

  def destroy

    @route.destroy

    redirect_to routes_path, notice: 'ルートを削除しました'

  end

  

  private

  

  def set_route

    @route = Route.find(params[:id])

  end

  

  def authorize_owner!

    unless @route.user == current_user || current_user&.is_admin?

      redirect_to routes_path, alert: 'アクセスが拒否されました'

    end

  end

  

  def route_params

    params.require(:route).permit(

      :name,

      :description,

      :city_id,

      :estimated_duration,

      :estimated_cost,

      :difficulty_level,

      :is_public,

      tag_ids: []

    )

  end

end

