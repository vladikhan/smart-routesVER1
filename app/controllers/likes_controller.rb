class LikesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_user!

  def create
    result =
      Like::Operation::Create.call(
        params: {
          user_id: current_user.id,
          likeable_id: params[:likeable_id],
          likeable_type: params[:likeable_type]
        }
      )

    if result.success?
      redirect_back fallback_location: root_path, notice: 'いいねしました'
    else
      redirect_back fallback_location: root_path, alert: 'エラーが発生しました'
    end
  end

  def destroy
    # Передаем params (там будет :id лайка) и current_user для проверки прав
    result =
      Like::Operation::Delete.call(params: params, current_user: current_user)

    if result.success?
      redirect_back fallback_location: root_path,
                    notice: 'いいねを取り消しました'
    else
      redirect_back fallback_location: root_path, alert: 'エラーが発生しました'
    end
  end
end
