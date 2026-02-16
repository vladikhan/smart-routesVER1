class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
  @user = User.find(params[:user_id])
  result = Follower::Operation::Create.call(
    params: { 
      follower_id:  current_user.id, 
      following_id: @user.id 
    }
  )

  respond_to do |format|
    if result.success?
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "follow_section_#{@user.id}",
          partial: 'users/follow_button',
          locals: { user: @user }
        )
      end
      format.html { redirect_back fallback_location: root_path(@user), notice: "フォローしました" }
    else
      # Если операция не удалась (например, уже подписан), 
      # Turbo запрос должен получить 422 или 200 с ошибкой, но не 303!
      format.turbo_stream {head :unprocessable_entity }
      format.html { redirect_back fallback_location: root_path(@user), alert: "エラーが発生しました" }
    end
  end
end

  def destroy
    @user = User.find(params[:user_id])
    result = Follower::Operation::Delete.call(params: params, current_user: current_user)

    if result.success?
      # Нам всё еще нужен объект пользователя для рендера кнопки, 
      # найдем его по ID из параметров
      render_follow_button
    else
      redirect_back fallback_location: root_path(@user), alert: 'ユーザーが見つからないか、解除に失敗しました'
    end
  end

  private

  def render_follow_button
  respond_to do |format|
    format.turbo_stream do # <--- Rails должен зайти сюда
      render turbo_stream: turbo_stream.replace(
        "follow_section_#{@user.id}",
        partial: 'users/follow_button',
        locals: { user: @user }
      )
    end
    format.html { redirect_back fallback_location: root_path }
  end
end
end

