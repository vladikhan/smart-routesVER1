class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_user, only: [:show]
  before_action :authorize_user!, only: [:edit, :update]

  # GET /users - список пользователей
  def index
    @users = User.where(confirmed_at: nil..).order(created_at: :desc).page(params[:page]).per(20)
  end

  # GET /my_profile - редирект на профиль текущего пользователя
  def my_profile
    if user_signed_in?
      redirect_to user_path(current_user)
    else
      redirect_to login_path, alert: 'ログインしてください。'
    end
  end

  # GET /users/:id
  def show
    @routes = @user.routes.where(is_public: true).order(created_at: :desc).limit(6)
    @reviews = @user.reviews.order(created_at: :desc).limit(5)
  end

  # GET /users/:id/edit
  def edit
    @user = current_user
  end

  # PATCH /users/:id
  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'プロフィールが更新されました。'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    unless current_user == User.find(params[:id])
      redirect_to root_path, alert: 'アクセスが拒否されました。'
    end
  end

  def user_params
    params.require(:user).permit(:username, :bio, :location, :avatar, :remove_avatar)
  end
end
