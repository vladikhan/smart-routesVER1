class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    result = Bookmark::Operation::Create.call(params: params, current_user: current_user)

    if result.success?
      @item = result[:item]
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: '保存しました！' }
        format.json { render json: { success: true, bookmarks_count: @item.reload.bookmarks_count } }
      end
    else
      render_error('すでに保存されています')
    end
  end

  def destroy
    result = Bookmark::Operation::Delete.call(params: params, current_user: current_user)

    if result.success?
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: '保存を解除しました' }
        format.json { render json: { success: true, bookmarks_count: result[:item].reload.bookmarks_count } }
      end
    else
      render_error('保存が見つかりません')
    end
  end

  def index
    @bookmarked_items = current_user.bookmarks
                                    .includes(item: { images_attachments: :blob })
                                    .order(created_at: :desc)
                                    .page(params[:page]).per(12)
  end

  private

  def render_error(message)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.json { render json: { success: false, error: message }, status: :unprocessable_entity }
    end
  end
end
