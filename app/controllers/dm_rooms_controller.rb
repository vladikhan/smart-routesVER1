class DmRoomsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    run_index
  end

  def show
  @room = DmRoom.find(params[:id])

  unless @room.sender_id == current_user.id || @room.receiver_id == current_user.id
    redirect_to dm_rooms_path, alert: 'このチャットルームにはアクセスできません。'
    return 
  end

  @other_user = (@room.sender == current_user) ? @room.receiver : @room.sender
  @messages = @room.dm_messages.includes(:user).order(created_at: :asc)
  
  run_index 

  @room.dm_messages.where.not(user_id: current_user.id).update_all(is_read: true)

  render :index
end


  def create
    @room = DmRoom.find_or_create_between(current_user.id, params[:receiver_id])
    if @room.persisted? # или if @room.save
      redirect_to dm_room_path(@room)
    else
      redirect_to root_path 
    end
  end

  def mark_all_as_read
    @dm_room = DmRoom.find_by(id: params[:id])

    # 2. Если комната не найдена — выходим
    return head :not_found if @dm_room.nil?

    # 3. Проверяем, является ли текущий юзер участником
    unless @dm_room.participant?(current_user)
      return head :forbidden
    end

    # 4. Обнуляем счетчики непрочитанных
    # Определяем, кто сейчас читает: создатель или получатель
    @dm_room.update_columns(
      unread_count_sender: 0,
      unread_count_receiver: 0
    )

    # 5. Помечаем все сообщения в комнате как прочитанные
    @dm_room.mark_all_as_read_for(current_user)
    
    head :ok
  end

  private


  def run_index
    result = DmRoom::Operation::Index.call(params: params, current_user: current_user)
    @dm_rooms    = result[:dm_rooms].includes(:sender, :receiver)
    @active_room = result[:active_room]
    @messages    = result[:messages] || [] 
  end
end


