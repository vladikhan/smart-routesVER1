class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    @item = params[:item_type].constantize.find(params[:item_id])
    @bookmark = current_user.bookmarks.build(item: @item)

    if @bookmark.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: '保存しました！' }
        format.json { render json: { success: true, bookmarks_count: @item.reload.bookmarks_count } }
      end
    else
      render_error('すでに保存されています')
    end
  end

  def destroy
    # Так как мы используем 'resource' (ед. число), ID в params[:id] не придет.
    # Ищем закладку текущего пользователя для этого конкретного объекта.
    @bookmark = current_user.bookmarks.find_by(
      item_type: params[:item_type],
      item_id: params[:item_id]
    )

    if @bookmark&.destroy
      @item = @bookmark.item
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: '保存を解除しました' }
        format.json { render json: { success: true } }
      end
    else
      render_error('保存が見つかりません')
    end
  end

  def index
    @bookmarked_items = current_user.bookmarks.includes(:item).order(created_at: :desc).page(params[:page]).per(12)
  end

  private

  def render_error(message)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: message }
      format.json { render json: { success: false, error: message }, status: :unprocessable_entity }
    end
  end
end
