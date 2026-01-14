module NotificationsHelper
  def notificaiton_text_for(notification)
    case notification.notification_type
    when 'new_message'
      "#{notification.actor.username}から新しいメッセージが届きました"
    when 'follow'
      'あなたの更新を購読しました'
    when 'like'
      'あなたのルートを評価しました'
    else
      '新しい通知が届いています'
    end
  end
end
