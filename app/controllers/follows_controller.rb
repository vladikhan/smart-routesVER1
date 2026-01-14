class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find(params[:user_id])

    if current_user.follow(@user)
      @user.reload
      respond_to do |format|
        format.html { redirect_back fallback_location: @user, notice: 'フォローしました' }
        format.json { render json: { success: true, followers_count: @user.followers_count } }
      end
    else
      render_error
    end
  end

  def destroy
    @user = User.find(params[:user_id])

    if current_user.unfollow(@user)
      @user.reload

      respond_to do |format|
        format.html { redirect_back fallback_location: @user, notice: 'フォローを解除しました' }
        format.json { render json: { success: true, followers_count: @user.followers.count } }
      end
    else
      render_error
    end
  end

  private

  def render_error
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'エラーが発生しました' }
      format.json { render json: { success: false, error: 'エラーが発生しました' } }
    end
  end
end
