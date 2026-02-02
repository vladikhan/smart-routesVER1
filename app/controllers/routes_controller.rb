class RoutesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  def index
    result = Route::Operation::Index.call(params: params)
    @routes = result[:model]
  end

  def show
  result = Route::Operation::Show.call(params: params, current_user: current_user)
  
  if result.success?
    @route = result[:model]
    # Вот тут важно! Мы берем подготовленный массив из операции
    @route_items = result[:map_items] 
    @related_routes = result[:related_routes]
    # Если в операции ты сохранил это в ctx[:route_items], то бери этот ключ
    @reviews = @route.reviews.includes(:user)
  else
    redirect_to routes_path, alert: "Route not found"
  end
end

  def new
    # Для метода new нам всё еще нужна пустая модель и данные для селектов
    @route = Route.new
    @cities = City.order(:name)
    @venues = Venue.order(:name)
  end

  def edit
    # Используем операцию, чтобы найти модель и проверить права доступа
    result = Route::Operation::Update.call(params: params, current_user: current_user)
    
    if result.failure?
      return redirect_to routes_path, alert: 'アクセス権限がありません'
    end

    @route = result[:model]
    @cities = City.order(:name)
    @venues = Venue.order(:name)
  end

  def create
    result = Route::Operation::Create.call(params: params.to_unsafe_h, current_user: current_user)

    if result.success?
      redirect_to result[:model], notice: 'ルートが作成されました'
    else
      @route = result[:model]
      @cities = City.order(:name)
      @venues = Venue.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    result = Route::Operation::Update.call(params: params.to_unsafe_h, current_user: current_user)

    if result.success?
      redirect_to result[:model], notice: 'ルートを更新しました'
    else
      @route = result[:model]
      @cities = City.order(:name)
      @venues = Venue.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Используем операцию для удаления
    result = Route::Operation::Delete.call(params: params, current_user: current_user)

    if result.success?
      redirect_to routes_path, notice: 'ルートが削除されました'
    else
      redirect_to routes_path, alert: '削除権限がありません'
    end
  end

  private

  def set_user_interaction_data
    @current_user_liked = current_user.liked?(@route)
    @current_user_bookmarked = current_user.bookmarked?(@route)
    @current_user_following = current_user.following?(@route.user)
    @user_like = current_user.likes.find_by(likeable: @route)
    @user_bookmark = current_user.bookmarks.find_by(item: @route)
  end
end