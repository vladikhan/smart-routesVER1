class UsersController < ApplicationController
	before_action :authenticate_user!, except: [:show]
	before_action :set_user, only: [:show]
	before_action :authorize_user!, only: [:edit, :update]

	def new 
		@user = User.new
	end

	def show
		@routes = @user.routes.where(is_public: true).order(created_at: :desc).limit(6)
		@reviews = @user.reviews.includes(:venue).order(created_at: :desc).limit(5)
	end

	def edit
		@user = current_user
	end

	def update 
		@user = current_user

		if @user.update(user_params)
			redirect_to user_path(@user), notice: 'プロフィールが更新されました。'
		else
			render :edit
		end
	end

	def create
		@user = User.new(user_params)
		if @user.save
			redirect_to root_path, notice: "登録完了しました！"
		else
			render :new
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
		params.require(:user).permit(:username, :bio, :location, :avatar, :remove_avatar, :email, :password, :password_confirmation)
	end
end
