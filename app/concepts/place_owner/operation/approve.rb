# app/concepts/place_owner/operation/approve.rb
module PlaceOwner::Operation
  class Approve < Trailblazer::Operation
    step :find_model!
    step :approve_and_claim_venue!
    step :notify_user!

    def find_model!(ctx, params:, **)
      ctx[:model] = PlaceOwner.find_by(id: params[:id])
    end

    def approve_and_claim_venue!(ctx, model:, **)
      # Оборачиваем в транзакцию
      PlaceOwner.transaction do
        model.status_approved! # Меняем статус через enum метод
        model.venue.update!(
          is_claimed: true, 
          claimed_at: Time.current
        )
      end
    rescue => e
      ctx[:error] = e.message
      false
    end

    def notify_user!(ctx, model:, **)
      Notification::Operation::Create.call(params: {
        notification: {
          user_id: model.user_id,
          action: 'mention',
          notifiable: model.venue,
          message: "店舗「#{model.venue.name}」のオーナー確認が完了しました！"
        }
      })
      true
    end
  end
end