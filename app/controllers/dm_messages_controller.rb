class DmMessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    result = DmMessage::Operation::Index.call(params: params, current_user: current_user)

    if result.success?
      @dm_room = result[:dm_room]
      @dm_message = result[:model]
    else
      redirect_to dm_rooms_path, alert: 'アクセス権限がないか、チャットルームが見つかりません'
    end
  end

  def create
    result = DmMessage::Operation::Create.call(params: params, current_user: current_user)

    if result.success?
      respond_to do |format|
        format.html { redirect_to dm_room_path(result[:dm_room]) }
        format.turbo_stream
        format.json { render json: result[:model], status: :created }
      end
    else

      error_msg = result['contract.default']&.errors&.full_messages&.join(',') || 'エラーが発生しました'
      redirect_to dm_room_path(params[:dm_room_id]), alert: error_msg
    end
  end

  def destroy
    result = DmMessage::Operation::Delete.call(params: params, current_user: current_user)

    if result.success?
      redirect_back fallback_location: root_path, notice: 'メッセージを削除しました'
    else
      redirect_back fallback_location: root_path, alert: '削除権限がないか、失敗しました'
    end
  end

  def mark_all_as_read
    @active_room = DmRoom.find(params[:id])
    
    if @active_room.participant?(current_user)
      @active_room.mark_all_as_read_for(current_user)
      head :ok 
    else
      head :forbidden
    end
  end

  private

  def sent_dm_room
    @dm_room = DmRoom.find(params[:dm_room_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dm_rooms_path, alert: '部屋が見つかりません
'
  end

  def dm_message_params
    permitted_params = params.permit(:text)
    { message: permitted_params[:text] }
  end

  def authorize_room_access
    return if @dm_room.sender_id == current_user.id || @dm_room.receiver_id == current_user.id

    redirect_to dm_rooms_path, alert: 'アクセス権限がありません'
  end
end
