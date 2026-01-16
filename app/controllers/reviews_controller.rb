# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_reviewable

  def index
    @reviews = @reviewable.reviews.includes(:user).recent.page(params[:page]).per(10)
  end

  def create
    @review = @reviewable.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      respond_to do |format|
        format.html { redirect_back(fallback_location: polymorphic_path(@reviewable), notice: 'レビューを投稿しました') }
        format.json { render json: { success: true, review: review_json(@review) } }
      end
    else
      respond_to do |format|
        format.html do
          redirect_back(fallback_location: polymorphic_path(@reviewable),
                        alert: @review.errors.full_messages.join(', '))
        end
        format.json do
          render json: { success: false, errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    @review = current_user.reviews.find(params[:id])

    if @review.update(review_params)
      respond_to do |format|
        format.html { redirect_back(fallback_location: polymorphic_path(@reviewable), notice: 'レビューを更新しました') }
        format.json { render json: { success: true, review: review_json(@review) } }
      end
    else
      respond_to do |format|
        format.html do
          redirect_back(fallback_location: polymorphic_path(@reviewable),
                        alert: @review.errors.full_messages.join(', '))
        end
        format.json do
          render json: { success: false, errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: polymorphic_path(@reviewable), notice: 'レビューを削除しました') }
      format.json { render json: { success: true } }
    end
  end

  private

  def set_reviewable
    if params[:route_id]
      @reviewable = Route.find(params[:route_id])
    elsif params[:venue_id]
      @reviewable = Venue.find(params[:venue_id])
    end
  end

  def review_params
    params.require(:review).permit(:total_score, :text)
  end

  def review_json(review)
    {
      id: review.id,
      rating: review.total_score,
      content: review.text,
      user: {
        username: review.user.username,
        avatar_url: review.user.avatar_url
      },
      created_at: l(review.created_at, format: :long)
    }
  end
end
