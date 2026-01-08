class DmMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :sent_dm_rooms

  def create
    return render json: { error: 'Access denied' }, status: :firbidden unless @dm_room.participant?(current_user)

    @dm_messages = @dm_room.dm_messages.build(dm_message_params)
    @dm_message.user = current_user

    if @dm_message.save
      respond_to do |format|
        format.html { redirect_to dm_room_path(@dm_room) }
        fromat.json do
          render json: {
            message: @dm_message,
            html: render_to_string(partial: 'dm_messages/message',
                                   locals: { message: @dm_message, user: current_user }, formats: [:html])
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

  def set_dm_room
    @dm_room = DmRoom.find(params[:dm_room_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dm_rooms_path, alert: 'Room not found'
  end

  def dm_message_params
    params.require(:dm_message).permit(:message, :image)
  end
end
