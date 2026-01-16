class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_user, only: %i[show edit update]
  before_action :authorize_user!, only: %i[edit update]

  def index
    @users = User.includes(:routes, :reviews)
                 .page(params[:page])
                 .per(20)
  end

  def show
    @reviews = @user.reviews.includes(:reviewable).recent.order(created_at: :desc)
    @activities = []
    @routes = @user.routes.recent

    @user.routes.recent.limit(10).each do |r|
      @activities << { type: 'route', created_at: r.created_at, icon: '🗺️', text: "新しいルート「#{r.name}」を作成しました", obj: r }
    end

    # 2. Лайки
    @user.likes.includes(:likeable).order(created_at: :desc).limit(10).each do |l|
      next unless l.likeable.respond_to?(:name)

      @activities << { type: 'like', created_at: l.created_at, icon: '❤️', text: "「#{l.likeable.name}」にいいねしました",
                       obj: l.likeable }
    end

    @user.reviews.recent.limit(10).each do |rev|
      @activities << { type: 'review', created_at: rev.created_at, icon: '📝', text: 'レビューを投稿しました',
                       obj: rev.reviewable }
    end

    # Сортируем и пагинируем массив
    @activities = @activities.sort_by { |a| a[:created_at] }.reverse
    @activities = Kaminari.paginate_array(@activities).page(params[:activity_page]).per(10)

    Rails.logger.debug "DEBUG: Activities count for  #{@user.username}: #{@activities.count}"
    puts "DEBUG: ACtivities: #{@activities.inspect}"

    base_routes = if current_user == @user
                    @user.routes.order(created_at: :desc).page(params[:page]).per(10)
                  else
                    @user.routes.where(is_public: true)
                         .order(created_at: :desc)
                         .page(params[:page]).per(10)
                  end
    @routes = base_routes.includes(:city, :tags).order(created_at: :desc)
                         .limit(20)

    @saved_routes = @user.bookmarked_routes.includes(:city, :tags)
                         .order('bookmarks.created_at DESC').limit(20)

    @reviews = @user.reviews.includes(:reviewable).recent.page(params[:review_page]).per(10)

    @followers_count = @user.followers.count

    @following_count = @user.following.count
  end

  def my_profile
    redirect_to user_path(current_user)
  end

  def edit
    # @user is already set by before_action
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'プロフィールを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    return if current_user == @user || current_user&.is_admin?

    redirect_to routes_path, alert: 'アクセスが拒否されました'
  end

  def user_params
    params.require(:user).permit(
      :username,
      :bio,
      :location,
      :avatar,
      :budget_min,
      :budget_max
    )
  end
end
