class DmMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :sent_dm_room

  def index
    @dm_messages = DmMessage
                   .includes(:dm_room, :user)
                   .where(user_id: current_user.id)
                   .order(created_at: :desc)
  end

  def create
    return render json: { error: 'Access denied' }, status: :forbidden unless @dm_room.participant?(current_user)

    @dm_message = @dm_room.dm_messages.build(dm_message_params)
    @dm_message.user = current_user

    if @dm_message.save
      @dm_room.touch(:last_message_at)
      @dm_room.increment_unread_for(current_user)
      receiver = @dm_room.sender
      @dm_room.increment_unread_for(receiver) if receiver

      respond_to do |format|
        format.html { redirect_to dm_room_path(@dm_room) }
        format.json do
          render json: {
            message: @dm_message,
            html: render_to_string(partial: 'dm_messages/message',
                                   locals: { dm_message: @dm_message, user: current_user },
                                   formats: [:html])
          }, status: :created
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to dm_room_path(@dm_room), alert: 'メッセージの送信に失敗しました' }
        format.json { render json: { errors: @dm_message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def sent_dm_room
    @dm_room = DmRoom.find(params[:dm_room_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dm_rooms_path, alert: 'Room not found'
  end

  def dm_message_params
    permitted_params = params.permit(:content)
    { message: permitted_params[:content] }
  end
end
