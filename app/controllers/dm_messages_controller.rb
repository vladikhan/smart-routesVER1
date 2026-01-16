class DmMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :sent_dm_room
  before_action :authorize_room_access

  def index
    @dm_messages = DmMessage
                   .includes(:dm_room, :user)
                   .where(user_id: current_user.id)
                   .order(created_at: :desc)
  end

  def create
    # 1. Проверка доступа
    return render json: { error: 'Access denied' }, status: :forbidden unless @dm_room.participant?(current_user)

    @dm_message = @dm_room.dm_messages.build(dm_message_params)
    @dm_message.user = current_user

    if @dm_message.save
      @dm_room.touch(:updated_at)

      # 3. Увеличиваем счетчик ТОЛЬКО для получателя
      receiver = @dm_room.other_user(current_user)
      @dm_room.increment_unread_for(receiver) if receiver

      # 4. Создаем уведомление через наш новый сервис
      NotificationService.notify_new_message(@dm_message)

      html = render_to_string(partial: 'dm_messages/message', locals: { message: @dm_message })

      ActionCable.server.broadcast("dm_room_#{@dm_room.id}", {
                                     message: html,
                                     sender_id: current_user.id
                                   })

      respond_to do |format|
        format.html { redirect_to dm_room_path(@dm_room) }
        format.json { render json: @dm_message, status: :created }
      end
    else
      error_msg = @dm_message.errors.full_messages.join(', ')

      respond_to do |format|
        format.html { redirect_to dm_room_path(@dm_room), alert: "送信エラー: #{error_msg}" }
        format.js   { render js: "alert('#{error_msg}');" }
        format.json { render json: { errors: @dm_message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @dm_message = @dm_room.dm_messages.find(params[:id])

    return if @dm_message.user == current_user

    redirect_to dm_room_path(@dm_room), alert: '削除権限がありません'

    @dm_message.destroy
    redirect_to dm_room_path(@dm_room), notice: 'メッセージを削除しました'
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
