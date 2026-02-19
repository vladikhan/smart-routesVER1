class DmMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dm_room, only: [:destroy, :mark_all_as_read]

  def index
    result = DmMessage::Operation::Index.call(params: params, current_user: current_user)

    if result.success?
      @dm_room = result[:dm_room]
      @messages = result[:model]
      @dm_message = DmMessage.new
      @other_user = @dm_room.other_user(current_user)
    else
      redirect_to dm_rooms_path, alert: 'アクセス権限がないか、チャットルームが見つかりません'
    end
  end

  def create
  # Ищем комнату
  @dm_room = DmRoom.find_by(id: params[:dm_room_id])

  # 1. Если комнаты нет ИЛИ юзер не участник — СРАЗУ выдаем 403 для JS
  if @dm_room.nil? || !@dm_room.participant?(current_user)
    respond_to do |format|
      format.js { head :forbidden and return } 
      format.html { redirect_to dm_rooms_path, alert: 'Access denied' and return }
      format.any { head :forbidden }
    end
    return
  end

  # 2. Если всё ок, вызываем операцию
  result = DmMessage::Operation::Create.call(
    params: params, 
    current_user: current_user
  )

  if result.success?
    @message = result[:model]
    respond_to do |format|
      format.html { redirect_to dm_room_path(@dm_room) }
      format.js   { head :ok }  
      format.turbo_stream { head :ok }
      format.json {
        render json: { message: @message.message}, status: :created 
      }
    end
  else
    # 3. Если упала валидация (например, пустое сообщение)
    handle_create_failure(result)
  end
end

  def destroy
    @dm_message = @dm_room.dm_messages.find_by(id: params[:id], user_id: current_user.id)
    
    if @dm_message
    @dm_message.destroy
    broadcast_deletion(params[:id])
    
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'メッセージを削除しました' }
      format.js   { head :ok } # JSリクエストなら 200 OK
    end
  else
    # メッセージが見つからない（＝他人のもの、または存在しない）場合
    respond_to do |format|
      format.html { redirect_to dm_room_path(@dm_room), alert: '権限がありません' }
      format.js   { head :forbidden } # ← これがテストが求めている 403 Forbidden です！
    end
  end
  end

  def update
    @dm_room = DmRoom.find(params[:dm_room_id])
    
    # Находим сообщение, которое хотим обновить
    @dm_message = DmMessage.find_by(id: params[:id])

    if @dm_message.nil? || @dm_message.user_id != current_user.id
      return head :forbidden 
    end

    result = DmMessage::Operation::Update.call(params: params, current_user: current_user)

    if result.success?
      ActionCable.server.broadcast("dm_room_#{@dm_room.id}", { 
        action: 'update', 
        message: {
          id: result[:model].id,
          content: result[:model].message
        } 
      })
      head :ok
    else
      handle_create_failure(result)
    end
end

  def mark_all_as_read
    unless @dm_room.participant?(current_user)
      return head :forbidden
    end

    @dm_room.mark_all_as_read_for(current_user)
    # Важно: после вызова метода выше, счетчик должен стать 0
    head :ok
  end

  private

  def set_dm_room
    room_id = params[:dm_room_id] || params[:id]
    @dm_room = DmRoom.find(room_id)
  end

  def handle_create_failure(result)
  # Достаем контракт
  contract = result['contract.default']
  
  

  # Собираем сообщение об ошибке
  alert_msg = contract&.errors&.full_messages&.join(', ').presence || 'エラーが発生しました'

  if result['result.policy.default']&.failure? || !@dm_room.participant?(current_user)
    return redirect_to dm_rooms_path, alert: 'アクセス権限がありません'
  end

  respond_to do |format|
    format.html { redirect_to dm_room_path(@dm_room), alert: alert_msg }
    format.json { render json: { errors: contract&.errors&.messages }, status: :unprocessable_entity }
    format.js { render js: "alert('#{alert_msg}');", status: :unprocessable_entity }
    format.turbo_stream { head :unprocessable_entity }
  end
end

  def broadcast_deletion(message_id)
    
    ActionCable.server.broadcast("dm_room_#{@dm_room.id}", {
      message_id: message_id.to_i,
      action: 'delete'
    })
  end
end