class DmMessage::Operation::Update < Trailblazer::Operation
  step :model
  step :check_owner
  step :update_message

  def model(ctx, params:, **)
    ctx[:model] = DmMessage.find_by(id: params[:id])
  end

  def check_owner(ctx, model:, current_user:, **)
    model.user_id == current_user.id
  end

  def update_message(ctx, model:, params:, **)
    message_text = params.dig(:dm_message, :text) || params.dig(:dm_message, :message)
    model.update(message: message_text)
  end
end