class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @likeable = params[:likeable_type].constantize.find(params[:likeable_id])
    @like = @likeable.likes.build(user: current_user)

    if @like.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'いいねしました！' }
        format.json do
          render json: { success: true, likes_count: @likeable.reload.likes_count,
                         message: 'いいねしました！' }
        end
      end
    else
      render_error
    end
  end

  def destroy
    @like = current_user.likes.find_by(
      likeable_type: params[:likeable_type],
      likeable_id: params[:likeable_id]
    )

    if @like&.destroy
      @likeable = @like.likeable
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'いいねを取り消しました' }
        format.json do
          render json: {
            success: true,
            likes_count: @likeable.reload.likes_count,
            message: 'いいねを取り消しました'
          }
        end
      end
    else
      render_error('いいねが見つかりません')
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
