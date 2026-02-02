class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    result = Follower::Operation::Create.call(
      params: { 
        follower_id:  current_user.id, 
        following_id: params[:user_id] 
      }
    )

    if result.success?
      @user = result[:model].following # Тот, на кого подписались
      render_follow_button
    else
      redirect_back fallback_location: root_path, alert: 'エラーが発生しました'
    end
  end

  def destroy
    result = Follower::Operation::Delete.call(params: params, current_user: current_user)

    if result.success?
      # Нам всё еще нужен объект пользователя для рендера кнопки, 
      # найдем его по ID из параметров
      @user = User.find(params[:user_id])
      render_follow_button
    else
      redirect_back fallback_location: root_path, alert: 'ユーザーが見つからないか、解除に失敗しました'
    end
  end

  private

  def render_follow_button
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "follow_section_#{@user.id}",
          partial: 'users/follow_button',
          locals: { user: @user }
        )
      end
      format.html { redirect_back fallback_location: user_path(@user) }
    end
  end
end
