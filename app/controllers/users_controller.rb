# Encoding: UTF-8
class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def index
    @users = User.includes(:routes, :reviews)
                 .page(params[:page])
                 .per(20)
  end

  def show
    # Show all routes if viewing own profile, only public if viewing others
    if current_user == @user
      @routes = @user.routes.order(created_at: :desc).page(params[:page]).per(10)
    else
      @routes = @user.routes.where(is_public: true)
                           .order(created_at: :desc)
                           .page(params[:page]).per(10)
    end
    @routes = @routes.includes(:city, :tags).limit(20)
    @followers_count = @user.followers.count rescue 0
    @following_count = @user.following.count rescue 0

    @reviews = Review.where(user_id: @user.id).order(created_at: :desc)
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
    unless current_user == @user || current_user&.is_admin?
      redirect_to routes_path, alert: 'アクセスが拒否されました'
    end
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
