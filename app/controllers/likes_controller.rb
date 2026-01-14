class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @likeable = params[:likeable_type].constantize.find(params[:likeable_id])
    @like = @likeable.likes.build(user: current_user)

    if @like.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.json { render json: { success: true, likes_count: @likeable.reload.likes_count } }
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
      render json: { success: true, likes_count: @likeable.reload.likes_count }
    else
      render json: { success: false, errors: ['Like not found'] }, status: :not_found
    end
  end

  private

  def render_error
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'エラーが発生しました' }
      format.json { render json: { success: false }, status: :unprocessable_entity }
    end
  end
end
