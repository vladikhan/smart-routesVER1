# encoding: UTF-8
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :entity, polymorphic: true, optional: true

  validates :notification_type, presence: true
  validates :notification_type, inclusion: {
    in: %w[follow like comment review message route_featured venue_approved]
  }
  # スコープ
  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }

  # メソッド
  def mark_as_read!
    update(is_read: true) unless is_read?
  end

  def unread_
    !is_read?
  end

  def notifiable
    return nil unless entity_type && entity_id
    entity_type.constantize.find_by(id: entity_id)
  end

  def message
    case notification_type
    when 'route_shared'
      '#{actor.username}さんがルートをシェアしました'
    when 'like'
      '#{actor.username}さんがあなたの#{entity_type_japanese}にいいねしました'
    when 'comment'
      '#{actor.username}さんがコメントしました。'
    when 'review'
       "#{actor.username}さんがレビューを投稿しました"
    when 'follow'
      "#{actor.username}さんがフォローしました"
    else
      "新しい通知があります"
    end
  end

  def icon
    case notification_type
    when 'route_shared' then '📤'
    when 'like' then '❤️'
    when 'comment' then '💬'
    when 'review' then '⭐'
    when 'follow' then '👤'
    else '🔔'
    end
  end

  private

  def entity_type_japanese
    case entity_type
    when 'Route' then 'ルート'
    when 'Venue' then '場所'
    when 'Review' then 'レビュー'
    else 'コンテンツ'
    end
  end
end
