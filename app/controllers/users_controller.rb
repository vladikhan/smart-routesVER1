# Encoding: UTF-8
class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]

  before_action :set_user, only: [:show, :edit, :update]

  def index

    @users = User.order(created_at: :desc)

    

    # Search filter

    if params[:q].present?

      @users = @users.where('username LIKE ? OR bio LIKE ?', 

                            "%#{params[:q]}%", "%#{params[:q]}%")

    end

    

    @users = @users.page(params[:page]).per(20)

  end

  def show
    @routes = @user.routes.where(is_public: true)
                          .order(created_at: :desc)
                          .limit(6)

    @reviews = @user.reviews
                    .includes(:reviewable)
                    .order(created_at: :desc)
                    .limit(5)
  end

  def my_profile

    redirect_to user_path(current_user)

  end

  def edit

    authorize_user!

  end

  def update

    authorize_user!

    

    if @user.update(user_params)

      redirect_to @user, notice: 'プロフィールが更新されました。'

    else

      render :edit, status: :unprocessable_entity

    end

  end

  private

  def set_user

    @user = User.find(params[:id])

  end

  def user_params

    params.require(:user).permit(

      :username,

      :bio,

      :location,

      :budget_min,

      :budget_max,

      :avatar

    )

  end

  def authorize_user!

    unless @user == current_user || current_user&.is_admin?

      redirect_to root_path, alert: 'アクセスが拒否されました。'

    end

  end

end

