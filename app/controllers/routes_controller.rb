class RoutesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  #GET /routes
  def index
    @routes = Route.where(is_public: true)
                   .includes(:user, :venues)
                   .page(params[:page])
                   .per(12)
  end

  #GET /routes/:id
  def show
    @routes.increment!(:view_count)
    @venues = @route.venues.includes(:district)
    @reviews = @route.reviews.includes(:user).order(created_at: :desc)
  end

  #GET /routes/new
  def new
    @route = current_user.routes.build
  end

  def create
    @route = current_user.routes.build(route_params)

    if @route.save
      redirect_to @route, notice: 'マルートが正常に作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  #GET /routes/:id/edit
  def edit
    authorize_owner!
  end

  #GET /routes/:id
  def update
    authorize_owner!

    if @route.update(route_params)
    redirect_to @route, notice: 'ルートが更新されました。'
  else
    render :edit, status: :unprocessable_entity
  end
end

#DELETE /routes/:id
def :destroy
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
    :name, :description, :estimated_duration,
    :estimated_cost, :difficulty_level, :is_public
  )
end

def authorize_owner!
  unless @route.user == current_user || current_user.is_admin?
    redirect_to routes_path, alert: 'アクセスが拒否されました。'
  end
end