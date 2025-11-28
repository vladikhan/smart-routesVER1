class RoutesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_routes, only: [:show, :edit, :update, :destroy]

  #GET /routes
  def index
    @routes = Route.where(is_public: true)
                   .includes(:user, :city)
                   .page(params[:page])
                   .per(12)

    #Filter by search query
    if params[:q].present?
      @routes = @routes.where('name LIKE ? OR description LIKE ?',
                              "%#{params[:q]}%", "%#{params[:q]}%")
    end

    #Filter by difficulty
    if params[:difficulty].present?
      @routes = @routes.where(difficulty_level: params[:difficulty])
    end

    # Filter by duration
    if params[:duration].present?
      case params[:duration]
      when 'short'
        @routes = @routes.where('estimated_duration <=?', 180)
      when 'medium'
        @routes = @routes.where('estimated_duration BETWEEN ? AND ? 181, 360')
      when 'long'
        @routes = @routes.where('estimated_durataion > ?', 360)
      end
    end

    # Filter by cost
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

    #Sort
    case params[:sort]
    when 'popular'
      @routes = @routes.order(view_count: :desc)
    when 'recent'
      @routes = @routes.order(created_at: :desc)
    when 'rating'
      @routes = @routes.order(average_raing: :desc)
    else
      @routes = @routes.order(created_at: :desc)
    end

    @routes = @routes.page(params[:page]).per(15)
  end

  #GET /routes/:id
  def show
    @route.increment!(:view_count)
    @route_items = @route.route_items.includes(:venue).order(position: :asc)
    @venues = @route.venues.includes(:district)
    @reviews = @route.reviews.includes(:user).order(created_at: :desc).limit(10)
  end

  #GET /routes/new
  def new
    @route = current_user.routes.build
    @cities = City.all
    @venues = Venue.all
  end

  def create
    @route = current_user.routes.build(route_params)

    if @route.save
      #Create route items from params
      create_route_items if params[:route_items].present?

      redirect_to @route, notice: 'ルートが正常に作成されました。'
    else
      render @cities = City.all
      render @venues = Venue.all
      render :new, status: :unprocessable_entity
    end
  end

  #GET /routes/:id/edit
  def edit
    authorize_owner!
    render @cities = City.all
    render @venues = Venue.all
  end

  #GET /routes/:id
  def update
    authorize_owner!

    if @route.update(route_params)
      #Update route items
      update_route_items if params[:route_items].present?

      redirect_to @route, notice: 'ルートが更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

#DELETE /routes/:id
def destroy
  authorize_owner!
  @route.destroy
  redirect_to routes_path, notice: 'ルートが削除されました。'
end

private

def set_routes
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

#Create route items from submitted form
def create_route_items
  params[:route_items].each_with_index do |item_params, index|
    next if item_params[:venue_id].blank?

    @route.route_items.create(
      venue_id: item_params[:venue_id],
      position: index + 1,
      duration_minutes: item_params[:duration_minutes].to_i,
      notes: item_params[:notes]
    )
  end
end

#Update route items (delete old ones, create new ones)

  def update_route_items
    #Delete existing route items
    @route.route_items.destroy_all

    #Create new route items
    create_route_items
  end
end