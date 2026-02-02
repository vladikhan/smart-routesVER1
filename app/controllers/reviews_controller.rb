class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reviewable
  before_action :set_review, only: %i[edit update destroy]

  def create
    result = Review::Operation::Create.call(
      params: params.to_unsafe_h,
      current_user: current_user,
      reviewable: @reviewable
    )

    if result.success?
      redirect_back(
        fallback_location: polymorphic_path(@reviewable),
        notice: 'レビューを投稿しました'
      )
    else
      errors = result['contract.default'].errors.full_messages.to_sentence
      redirect_back(
        fallback_location: polymorphic_path(@reviewable),
        alert: errors
      )
    end
  end

  def edit
    # Использует app/views/reviews/edit.html.erb
  end

  def update
    result = Review::Operation::Update.call(
      params: params.to_unsafe_h,
      current_user: current_user,
      model: @review
    )

    if result.success?
      redirect_back(fallback_location: polymorphic_path(@reviewable), notice: 'レビューの更新が正常に完了しました。
')
    else

      redirect_back(fallback_location: polymorphic_path(@reviewable), alert: '更新に失敗しました
')
    end
  end

  def destroy
    @review.destroy
    redirect_back(fallback_location: polymorphic_path(@reviewable), notice: 'レビューを削除しました')
  end

  private

  def set_reviewable
    @reviewable = params[:venue_id] ? Venue.find(params[:venue_id]) : Route.find(params[:route_id])
  end

  def set_review
    # Ищем отзыв и сразу проверяем владельца
    @review = Review.find_by(id: params[:id])

    redirect_to @reviewable, alert: 'アクセス権限がありません。' if @review.nil? || @review.user_id != current_user.id
  end

  def review_params
    params.require(:review).permit(:text, :score)
  end
end
