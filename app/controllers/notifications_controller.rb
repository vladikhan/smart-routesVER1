class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /notifications
  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .order(created_at: :desc)

    case params[:filter]
    when 'messages'     then @notifications = @notifications.message_notifications
    when 'interactions' then @notifications = @notifications.interaction_notifications
    when 'follows'      then @notifications = @notifications.follow_notifications
    end

    @notifications = @notifications.page(params[:page]).per(20)
    @unread_count = current_user.notifications.unread.count

    if params[:view] == 'activity'
      activity
    else
      # По умолчанию показываем Уведомления (твой текущий код)
      @notifications = current_user.notifications
                                   .includes(:actor, :notifiable)
                                   .order(created_at: :desc)

      case params[:filter]
      when 'messages'     then @notifications = @notifications.message_notifications
      when 'interactions' then @notifications = @notifications.interaction_notifications
      when 'follows'      then @notifications = @notifications.follow_notifications
      end

      @notifications = @notifications.page(params[:page]).per(20)
    end
  end

  # GET /notifications/unread_count
  def unread_count
    @unread_count = current_user.notifications.unread.count

    render json: {
      count: @unread_count,
      authenticated: true,
      user_id: current_user.id
    }
  rescue StandardError => e
    Rails.logger.error "❌ Error in unread_count: #{e.message}"
    render json: { count: 0, error: e.message }, status: :internal_server_error
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])

    if @notification.mark_as_read!
      # Используем метод target_url из модели Notification
      redirect_url = @notification.target_url

      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.json do
          render json: { success: true, redirect_url: redirect_url,
                         unread_count: current_user.notifications.unread.count }
        end
      end
    else
      render_error('Failed to update')
    end
  rescue ActiveRecord::RecordNotFound
    render_error('通知が見つかりません', :not_found)
  end

  # PATCH /notifications/mark_all_as_read
  def mark_all_as_read
    Notification.mark_all_as_read_for(current_user)

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました') }
      format.json { render json: { success: true, unread_count: 0 } }
    end
  rescue StandardError => e
    render_error('エラーが発生しました')
  end

  # GET /notifications/activity
  def activity
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    @activities = []

    # 1. Сбор созданных маршрутов
    @user.routes.order(created_at: :desc).limit(10).each do |r|
      @activities << {
        type: 'route',
        created_at: r.created_at,
        icon: '🗺️',
        text: "新しいルート「#{r.name}」を作成しました",
        obj: r
      }
    end

    # 2. Сбор лайков
    @user.likes.includes(:likeable).order(created_at: :desc).limit(10).each do |l|
      next unless l.likeable.respond_to?(:name)

      @activities << {
        type: 'like',
        created_at: l.created_at,
        icon: '❤️',
        text: "「#{l.likeable.name}」にいいねしました",
        obj: l.likeable
      }
    end

    # 3. Сбор комментариев (рецензий)
    @user.reviews.order(created_at: :desc).limit(10).each do |rev|
      @activities << {
        type: 'review',
        created_at: rev.created_at,
        icon: '📝',
        text: 'ルートにレビューを投稿しました',
        obj: rev
      }
    end

    # Сортировка по времени (самые свежие вверху)
    @activities = @activities.sort_by { |a| a[:created_at] }.reverse
    @activities = Kaminari.paginate_array(@activities).page(params[:page]).per(20)
  end

  private

  def render_error(message, status = :unprocessable_entity)
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, alert: message) }
      format.json { render json: { success: false, error: message }, status: status }
    end
  end
end
