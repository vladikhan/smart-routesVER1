class VenuesController < ApplicationController
  def index
    result = Venue::Operation::Index.call(params: params)
    @venues = result[:model]
  end

  def show
    result = Venue::Operation::Show.call(params: params, current_user: current_user)

    if result.success?
      @venue = result[:model]
      @routes = result[:public_routes]
      @featured_route = result[:featured_route]
      @route_items = result[:route_items]
    end
    
    if result.failure?
      return redirect_to venues_path, alert: "店舗が見つかりませんでした"
    end

    @venue       = result[:model]
    @routes      = result[:public_routes]
    @featured_route = result[:featured_route]
    @route_items = result[:route_items]
    # Если отзывов нет в результате операции, берем их из модели
    @reviews     = result[:reviews] || @venue.reviews.includes(:user).recent
  end

  def update
    result = Venue::Operation::Update.call(params: params.to_unsafe_h,                           id: params[:id],
                                           current_user: current_user      
    )

    if result.success?
      redirect_to venue_path(result[:model]), notice: '情報を更新しました'
    elsif result[:"result.policy.default"]&.failure?
      redirect_to root_path, alert: '他の人の店舗は編集できません'
    else
      @venue = result[:model]
      @form = result['contract.default']
      flash.now[:alert] = "入力内容にエラーがあります"
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_photo
    result = Venue::Operation::DeletePhoto.call(params: params)

    if result.success?
      flash[:notice] = '画像を削除しました'
    else
      flash[:alert] = '削除に失敗しました'
    end
    redirect_back(fallback_location: venue_path(params[:id]))
  end
end
