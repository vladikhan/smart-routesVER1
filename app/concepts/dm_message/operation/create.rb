class DmMessage::Operation::Create < Trailblazer::Operation
  step :setup_params!
  step :find_room!
  step :authorize!
  
  step Model(DmMessage, :new)
  step Contract::Build(constant: DmMessage::Contract::Create)
  step Contract::Validate(key: :dm_message)
  
  step :persist!
  step :update_room_and_counters!
  step :notify!
  step :broadcast!

   def setup_params!(ctx, params:, **)
     params[:dm_message] ||= {}
     params[:dm_message][:message] = params[:text] if params[:text]
     true
   end

   def find_room!(ctx, params:, **)
     ctx[:dm_room] = DmRoom.find_by(id: params[:dm_room_id])
   end

   def authorize!(ctx, dm_room:, current_user:, **)
     return false unless dm_room
     dm_room.participant?(current_user) 
   end

  def persist!(ctx, model:, dm_room:, current_user:, **)
    model.dm_room_id = dm_room.id
    model.user = current_user
    ctx['contract.default'].save 
  end

  def update_room_and_counters!(ctx, dm_room:, current_user:, **)
    dm_room.touch(:updated_at)
    receiver = dm_room.other_user(current_user)
    return true unless receiver
    dm_room.increment_unread_for(receiver) if receiver
  end

  def notify!(ctx, model:, dm_room:, current_user:, **)
    recipient = dm_room.other_user(current_user)
    return true unless recipient

    res = Notification::Operation::Create.call(params: {
      notification: {
        user_id: recipient.id,
        actor_id: current_user.id,
        notification_type: 'new_message',
        notifiable: model
      }
    })
    res.success?
  end

  def broadcast!(ctx, model:, dm_room:, current_user:, **)
    
    html = ApplicationController.render(
      partial: 'dm_messages/message',
      locals: { message: model, current_user: current_user }
    )

    ActionCable.server.broadcast("dm_room_#{dm_room.id}", {
      message: html,
      sender_id: current_user.id
    })
  end
end