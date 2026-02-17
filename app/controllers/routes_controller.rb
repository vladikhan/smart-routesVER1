class RoutesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  

  def index
    result = Route::Operation::Index.call(params: params)
    
    @routes = result[:routes] || result[:model] # Поддержка обоих ключей для надежности
    @featured_routes = result[:featured_routes]
    @cities = City.all
  end


  def show
  result = Route::Operation::Show.call(params: params, current_user: current_user)
  
  if result.success?
    @route = result[:model]
    @route_items = @route.route_items.includes(:item).map do |route_item|
      target = route_item.item 
      next if target.nil?

      {
        lat: target.geo_lat.to_f,
        lng: target.geo_lng.to_f,
        name: target.name,
        address: target.address,
        description: target.description # добавим для красоты
      }
    end.compact

    Rails.logger.debug "MAP DATA DEBUG: #{@map_data.inspect}"

    @user_liked = result[:user_liked]
    @user_bookmarked = result[:user_bookmarked]
    @like = result[:like]
    @bookmark = result[:bookmark]
    @related_routes = result[:related_routes]
    @reviews = @route.reviews.includes(:user) if @route.respond_to?(:reviews)
  else
    redirect_to routes_path, alert: "Route not found"
  end
end

  def new
  @route = Route.new
  3.times { @route.route_items.build } 
  @cities = City.all
end

  def route_params
  params.require(:route).permit(
    :name, :description, :is_public,
    route_items_attributes: [:id, :venue_name, :venue_address, :geo_lat, :geo_lng, :_destroy]
  )
end

  def create
    result = Route::Operation::Create.call(
      params: params.to_unsafe_h,
      current_user: current_user
    )

    if result.success?
      redirect_to route_path(result[:model]), notice: 'ルートを作成しました'
    else
      @route = result[:model]
      @cities = City.order(:name)
      @venues = Venue.order(:name) if defined?(Venue)
      # Используем безопасную навигацию для ошибок контракта
      flash.now[:alert] = result['contract.default']&.errors&.full_messages&.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # В Trailblazer для отображения формы редактирования часто используют отдельную операцию Present
    result = Route::Operation::Update::Present.call(params: params, current_user: current_user)
    
    if result.success?
      @route = result[:model]
      @form = result["contract.default"]
      @cities = City.order(:name)
      @venues = Venue.order(:name) if defined?(Venue)
    else
      redirect_to routes_path, alert: 'アクセス権限がありません'
    end
  end

  def update
    result = Route::Operation::Update.call(
      params: params.to_unsafe_h,
      current_user: current_user,
      id: params[:id]
    )


    if result.success?
      redirect_to route_path(result[:model]), notice: 'ルートを更新しました'
    elsif result['result.policy.default']&.failure?
      redirect_to routes_path, alert: '他の人のルートは編集できません'
    else
      @route = result[:model]
      @cities = City.order(:name)
      @venues = Venue.order(:name) if defined?(Venue)
      flash.now[:alert] = result['contract.default']&.errors&.full_messages&.join(', ') || '更新に失敗しました'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  @route = Route::Operation::Delete.call(params: params, current_user: current_user)

  if @route.success?
    flash[:notice] = 'ルートを削除しました'
    redirect_to routes_path, status: :see_other #see_other = 303 Error
  else
    flash[:alert] = 'このルートを削除する権限がありません'
    redirect_to route_path(@route[:model]), status: :forbidden
  end
  
  
end

  def route_params
  params.require(:route).permit(
    :name, :description, :city_id, :estimated_duration, :estimated_cost, :difficulty_level,
    tag_ids: [],
    route_items_attributes: [:id, :venue_name, :venue_address, :geo_lat, :geo_lng, :duration_minutes, :_destroy]
  )
end

  private

  # Метод оставлен на случай, если он используется в других частях или хелперах, 
  # но для основных действий теперь используются данные из Operations.
  def set_user_interaction_data
    return unless current_user && @route
    @current_user_liked = current_user.liked?(@route)
    @current_user_bookmarked = current_user.bookmarked?(@route)
    @user_like = current_user.likes.find_by(likeable: @route)
    @user_bookmark = current_user.bookmarks.find_by(item: @route)
  end
end