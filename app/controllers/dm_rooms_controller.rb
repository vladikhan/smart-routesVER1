class DmRoomsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    run_index
  end

  def show
    run_index
    render :index
  end

  def create
  @room = DmRoom.find_or_create_between(current_user.id, params[:receiver_id])
  if @room.persisted? # или if @room.save
    redirect_to dm_room_path(@room)
  else
    redirect_to root_path # Вот здесь тебя и редиректит!
  end
end


  private

  def run_index
    result = DmRoom::Operation::Index.call(params: params, current_user: current_user)
    @dm_rooms    = result[:dm_rooms].includes(:sender, :receiver)
    @active_room = result[:active_room]
    @messages    = result[:messages] || [] 
  end
end


