class UsersController < ApplicationController
  # 1. Сначала аутентификация, потом всё остальное
  before_action :authenticate_user!, except: %i[index show comments]
  # 2. Поиск юзера нужен только для простых экшенов, где нет Trailblazer операций
  before_action :set_user, only: %i[comments edit]
  # 3. Проверка прав (редактировать может только владелец или админ)
  before_action :authorize_user!, only: %i[edit update]

  def index
    @users = User.includes(:routes, :reviews)
                 .page(params[:page])
                 .per(20)
  end

  def show
    # Операция Show уже внутри себя делает: set_user, base_routes_scope и prepare_activities
    result = User::Operation::Show.call(params: params, current_user: current_user)
    
    if result.failure?
      return redirect_to users_path, alert: "ユーザーが見つかりません"
    end

    @user = result[:model]
    @routes = result[:routes]
    @saved_routes = result[:saved_routes]
    @activities = result[:activities]
    
    # Отзывы подгружаем отдельно с пагинацией
    @reviews = @user.reviews.includes(:reviewable).recent.page(params[:review_page]).per(10)
  end

  def edit
    result = User::Operation::Update.call(params: { id: params[:id] }, current_user: current_user)
    @user = result[:model]
    @form = result['contract.default']
  end

  def update
    result = User::Operation::Update.call(params: params.to_unsafe_h, current_user: current_user)

    if result.success?
      redirect_to user_path(result[:model]), notice: "プロフィールを更新しました"
    else
      @user = result[:model]
      @form = result['contract.default']

      render :edit, status: :unprocessable_entity
    end
  end

  def comments
    # Логика для отдельной вкладки комментариев
    @comments = @user.comments
                     .includes(:commentable)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(20)
  end

  def my_profile
    redirect_to user_path(current_user)
  end

  def follow

    @user = User.find_by(id: params[:id])

    return head :not_found unless @user

    result = User::Operation::Follow.call(params: params, current_user: current_user)

    respond_to do |format|
      if result.success?
        format.html { redirect_back fallback_location: root_path, notice: "フォローしました", status: :see_other }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "follow_section_#{@user.id}",
            partial: "users/follow_button",
            locals: { user: @user }
          )
        }
     
    else
      format.html { redirect_back fallback_location: root_path, alert: "エラーが発生しました", status: :see_other }
      format.turbo_stream { head :unprocessable_entity }
      # redirect_back fallback_location: root_path, alert: "エラーが発生しました", status: :see_other
    end
  end
end

def unfollow
  # 1. Находим пользователя в самом начале
  @user = User.find(params[:user_id] || params[:id])


  # 2. Выполняем операцию (один раз!)
  result = Follower::Operation::Delete.call(params: params, current_user: current_user)


  # 3. Отвечаем в зависимости от формата запроса
  respond_to do |format|
    if result.success?
      format.html { redirect_back fallback_location: root_path, notice: "フォロー解除済み", status: :see_other }
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "follow_section_#{@user.id}",
          partial: "users/follow_button", # Проверь: "users" или "user"? Обычно "users"
          locals: { user: @user }
        )
      }
    else
      format.html { redirect_back fallback_location: root_path, alert: "ユーザーが見つからないか、解除に失敗しました", status: :see_other }
      format.turbo_stream { head :unprocessable_entity }
    end
  end
end


  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to users_path, alert: 'ユーザーが見つかりませんでした'
  end

  def user_params
  params.require(:user).permit(:username, :birthday, :location, :gender, :bio, :avatar, :remove_avatar)
end

  def authorize_user!
    user_to_check = @user || User.find_by(id: params[:id])
    
    return if current_user == user_to_check || current_user&.admin?

    redirect_to root_path, alert: 'アクセス権限がありません'
  end
end