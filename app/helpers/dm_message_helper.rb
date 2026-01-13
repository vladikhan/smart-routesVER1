module DmMessageHelper
  def group_messages_by_date(messages)
    messages.group_by { |m| m.created_at.to_date }
  end

  def format_message_date(date)
    today = Date.current

    if date == Date.today
      '今日'
    elsif date == Date.yesterday
      '昨日'
    elsif date > today - 7.days
      I18n.l(date, format: '%A')
    else
      I18n.l(date, format: :long)
    end
  end

  def format_chat_time(time)
    return '' unless time

    now = Time.current
    diff_seconds = now - time

    case diff_seconds
    when 0..60
      '今'
    when 60..3600
      "#{(diff_seconds / 60).to_i}分前"
    when 3600..86_400
      "#{(diff_seconds / 3600).to_i}時間前"
    else
      I18n.l(time, format: '%H:%M')
    end
  end

  def message_sent_by_current_user?(message, current_user)
    message.user_id == current_user.id
  end

  def message_bubble_class(message, current_user)
    message_sent_by_current_user?(message, current_user) ? 'sent' : 'received'
  end
end
