class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @likeable = params[:likeable_type].constantize.find(params[:likeable_id])
    @like = @likeable.likes.find_or_initialize_by(user: current_user)

    if @like.save
      NotificationService.notify_route_liked(@like) if @likeable.is_a?(Route)
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'いいねしました！' }
        format.json do
          render json: { success: true, likes_count: @likeable.reload.likes_count,
                         message: 'いいねしました！' }
        end
      end
    else
      redirect_back fallback_location: root_path, alert: 'エラーが発生しました'
    end
  end

  def destroy
    # Находим лайк по ID, который пришел в URL
    @like = current_user.likes.find(params[:id])
    @likeable = @like.likeable

    @like.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: 'いいねを取り消しました' }
      format.json { head :no_content }
    end
  end

  private

  def render_error(message)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.json { render json: { success: false, error: message }, status: :unprocessable_entity }
    end
  end
end
