class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reviewable
  before_action :set_review, only: %i[edit update destroy]

  def create
    # return redirect_to @reviewable, alert: 'すでにレビューを投稿しています' if @reviewable.reviews.exists?(user_id: current_user.id)

    @review = @reviewable.reviews.build(review_params)
    @review.user = current_user
    @review.total_score ||= 5

    if @review.save

      NotificationService.notify_review_added(@review)
      redirect_back(
        fallback_location: polymorphic_path(@reviewable), notice: 'レビューを投稿しました'
      )
    else
      redirect_back(fallback_location: polymorphic_path(@reviewable),
                    alert: @review.errors.full_messages.to_sentence)
    end
  end

  def edit
    # Использует app/views/reviews/edit.html.erb
  end

  def update
    if @review.update(review_params)
      redirect_to @reviewable, notice: 'レビューを更新しました'
    else
      render :edit # Если ошибка, остаемся на форме редактирования
    end
  end

  def destroy
    @review.destroy
    redirect_back(fallback_location: polymorphic_path(@reviewable), notice: 'レビューを削除しました')
  end

  private

  def set_reviewable
    if params[:venue_id]
      @reviewable = Venue.find(params[:venue_id])
    elsif params[:route_id]
      @reviewable = Route.find(params[:route_id])
    end
  end

  def set_review
    # Ищем отзыв и сразу проверяем владельца
    @review = Review.find_by(id: params[:id])

    return unless @review.nil? || @review.user_id != current_user.id

    redirect_to @reviewable, alert: 'アクセス権限がありません。'
  end

  def review_params
    # Важно: используем :text, так как это имя колонки в твоей БД
    params.require(:review).permit(:total_score, :text)
  end
end
