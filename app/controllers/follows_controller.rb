class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    @user = User.find(params[:user_id])
    current_user.follow(@user)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("follow_section_#{@user.id}",
                                                  render_to_string(partial: 'users/follow_button',
                                                                   locals: { user: @user }))
      end
      format.html { redirect_back fallback_location: @user }
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.unfollow(@user)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("follow_section_#{@user.id}",
                                                  render_to_string(partial: 'users/follow_button',
                                                                   locals: { user: @user }))
      end
      format.html { redirect_back fallback_location: @user }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render_error
  end

  def render_error
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'エラーが発生しました' }
      format.json { render json: { success: false, error: 'ユーザーが見つかりません' }, status: :not_found }
    end
  end
end
