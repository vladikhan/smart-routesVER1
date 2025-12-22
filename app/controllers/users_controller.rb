class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :my_profile]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :check_user_authorization, only: [:edit, :update]

  def index
    @users = User.page(params[:page]).per(20)
  end
  
  def show
    if user_signed_in? && @user == current_user
      @routes = @user.routes.order(created_at: :desc)
    else
      @routes = @user.routes.where(is_public: true).order(created_at: :desc)
    end
  end

  def my_profile
    redirect_to user_path(current_user)
  end

  def edit
    @user = current_user
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'Профиль обновлен'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def check_user_authorization
    unless @user == current_user
      redirect_to root_path, alert: 'Доступ запрещен'
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :bio, :location, :avatar, :birthday, :gender)
  end
end