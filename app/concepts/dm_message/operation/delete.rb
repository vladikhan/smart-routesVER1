module DmMessage::Operation
  class Delete < Trailblazer::Operation
    step :find_message!
    step :authorize!
    step :destroy!

    def find_message!(ctx, params:, **)
      ctx[:model] = DmMessage.find_by(id: params[:id])
    end

    def authorize!(ctx, model:, current_user:, **)
      model.user_id == current_user.id
    end

    def destroy!(ctx, model:, **)
      model.destroy
    end
  end
end