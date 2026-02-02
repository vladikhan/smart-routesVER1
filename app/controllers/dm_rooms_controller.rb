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
    receiver = User.find(params[:receiver_id])

    @dm_room = DmRoom.find_or_create_between(current_user, receiver)

    redirect_to dm_room_path(@dm_room), notice: 'チャットを開始しました'
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'ユーザーが見つかりません'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: e.message
  end

  def mark_all_as_read
    @active_room = DmRoom.find(params[:id])
    @active_room.mark_all_as_read_for(current_user)
    head :ok
  end


  private

  def run_index
    result = DmRoom::Operation::Index.call(params: params, current_user: current_user)
    @dm_rooms    = result[:dm_rooms]
    @active_room = result[:active_room]
    @messages    = result[:messages] || [] 
  end
end


