module ApplicationHelper
  def render_stars(rating)
    content_tag :div, class: 'star-rating' do
      (1..5).map do |i|
        content_tag :span, i <= rating ? '★' : '☆', class: i <= rating ? 'star-filled' : 'star-empty'
      end.join.html_safe
    end
  end

  def user_avatar(user, size: 50, css_class: "")
    # 1. Если юзера нет, рисуем пустой круг
    return content_tag(:div, nil, class: "rounded-circle bg-light shadow-sm #{css_class}", style: "width:#{size}px; height:#{size}px;") if user.nil?

    # 2. Определяем URL: либо из Active Storage, либо из Dicebear
    avatar_url = if user.avatar.present?
                   user.avatar.thumb.url
                 else
                   "https://api.dicebear.com/7.x/identicon/svg?seed=#{user.username || 'guest'}"
                 end

    # 3. Генерируем финальный тег изображения
    image_tag avatar_url, 
              alt: user.username, 
              class: "rounded-circle object-fit-cover shadow-sm #{css_class}",
              style: "width: #{size}px; height: #{size}px;"
  end

  def date_label(date)
    case date
    when Date.today
      '今日'
    when Date.yesterday
      '昨日'
    else
      # Если год текущий, выводим только месяц и день, если старый — полный формат
      if date.year == Date.today.year
        date.strftime('%m月%d日')
      else
        date.strftime('%Y年%m月%d日')
      end
    end
  end

  def render_activity_text(activity)
  # Используем .user вместо .owner, так как в логах видно user_id
  user_name = activity.user ? activity.user.username : "退会済みユーザー"
  
  case activity.key
  when 'review.create'
    "#{user_name}さんが新しい口コミを投稿しました"
  when 'like.create'
    "#{user_name}さんがルートにいいね！しました"
  when 'follower.create' # Проверь ключи в базе, возможно 'user.follow'
    "#{user_name}さんにフォローされました"
  else
    "#{user_name}さんの新しいアクティビティです"
  end
  end
end