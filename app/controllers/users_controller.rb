class UsersController < ApplicationController
  # 1. Порядок в фильтрах: сначала проверка входа, потом поиск юзера
  before_action :authenticate_user!, except: %i[index show comments]
  before_action :set_user, only: %i[show edit update follow unfollow comments]
  before_action :authorize_user!, only: %i[edit update]

  def index
    @users = User.includes(:routes, :reviews)
                 .page(params[:page])
                 .per(20)
  end

  def show
    # Статистика для шапки профиля
    @followers_count = @user.followers.count
    @following_count = @user.following.count

    # Собираем ленту активностей (вынесено в private)
    prepare_activities

    # Маршруты: используем вспомогательный метод для фильтрации приватных
    @routes = base_routes_scope.includes(:city, :tags)
                               .order(created_at: :desc)
                               .limit(20)

    # Сохраненные маршруты
    @saved_routes = @user.bookmarked_routes.includes(:city, :tags)
                         .order('bookmarks.created_at DESC')
                         .limit(20)

    # Отзывы (Reviews)
    @reviews = @user.reviews.includes(:reviewable)
                    .recent
                    .page(params[:review_page])
                    .per(10)
  end

  def comments
    # Логика для отдельной вкладки комментариев
    @comments = @user.comments
                     .includes(:user, :commentable)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(20)

    # Чтобы шапка профиля на этой вкладке тоже работала
    @followers_count = @user.followers.count
    @following_count = @user.following.count
  end

  def my_profile
    redirect_to user_path(current_user)
  end

  def edit
    # @user уже найден через before_action
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'プロフィールを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def follow
    # Убираем лишний поиск User.find, так как есть before_action
    return unless current_user.follow(@user)

    NotificationService.create_notification(
      user: @user,
      actor: current_user,
      notification_type: 'follow',
      notifiable: @user
    )

    respond_to do |format|
      format.html { redirect_back fallback_location: user_path(@user), notice: 'フォローしました' }
      format.js   # Откроет follow.js.erb
    end
  end

  def unfollow
    return unless current_user.unfollow(@user)

    respond_to do |format|
      format.html { redirect_back fallback_location: user_path(@user), notice: 'フォローを解除しました' }
      format.js   # Откроет unfollow.js.erb
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to users_path, alert: 'ユーザーが見つかりませんでした'
  end

  # Логика: обычные люди видят только публичные маршруты, владелец видит всё
  def base_routes_scope
    current_user == @user ? @user.routes : @user.routes.where(is_public: true)
  end

  # Собираем активности в массив и пагинируем его
  def prepare_activities
    @activities = []

    # Добавляем маршруты
    @user.routes.recent.limit(10).each do |r|
      @activities << { type: 'route', created_at: r.created_at, icon: '🗺️', text: "新しいルート「#{r.name}」を作成しました", obj: r }
    end

    # Добавляем лайки (проверяем, что объект лайка существует)
    @user.likes.includes(:likeable).order(created_at: :desc).limit(10).each do |l|
      next unless l.likeable.respond_to?(:name)

      @activities << { type: 'like', created_at: l.created_at, icon: '❤️', text: "「#{l.likeable.name}」にいいねしました",
                       obj: l.likeable }
    end

    # Добавляем отзывы
    @user.reviews.recent.limit(10).each do |rev|
      @activities << { type: 'review', created_at: rev.created_at, icon: '📝', text: 'レビューを投稿しました', obj: rev.reviewable }
    end

    # Сортировка всего микса по дате
    @activities = @activities.sort_by { |a| a[:created_at] }.reverse
    @activities = Kaminari.paginate_array(@activities).page(params[:activity_page]).per(10)
  end

  def authorize_user!
    return if current_user == @user || current_user&.is_admin?

    redirect_to routes_path, alert: 'アクセスが拒否されました'
  end

  def user_params
    params.require(:user).permit(:username, :bio, :location, :avatar, :budget_min, :budget_max)
  end
end
