# encoding: UTF-8
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: 'User'
  
  validates :notification_type, presence: true
  validates :entity_type, presence: true
  validates :entity_id, presence: true
  
  scope :unread, -> { where(is_read: false) }
  scope :recent, -> { order(created_at: :desc) }

  def icon
    case notification_type
    when 'like'
      '❤️'
    when 'comment'
      '💬'
    when 'follow'
      '👤'
    when 'bookmark'
      '💾'
    when 'review'
      '⭐'
    else
      '🔔'
    end
  end
  
  def message
    I18n.t("notifications.messages.#{notification_type}",
           actor: actor.username,
           type: entity_type_japanese)
  rescue I18n::MissingTranslationData
    "#{actor.username}さんから通知があります"
  end
  
  def entity_type_japanese
    case entity_type
    when 'Route'
      'ルート'
    when 'Venue'
      '場所'
    when 'Review'
      'レビュー'
    when 'Comment'
      'コメント'
    else
      entity_type
    end
  end
  
  def target_url
    case entity_type
    when 'Route'
      "/routes/#{entity_id}"
    when 'Venue'
      "/venues/#{entity_id}"
    when 'Review'
      review = Review.find_by(id: entity_id)
      if review&.reviewable_type == 'Route'
        "/routes/#{review.reviewable_id}"
      elsif review&.reviewable_type == 'Venue'
        "/venues/#{review.reviewable_id}"
      else
        "/"
      end
    when 'Comment'
      comment = Comment.find_by(id: entity_id)
      if comment&.commentable_type == 'Route'
        "/routes/#{comment.commentable_id}"
      else
        "/"
      end
    else
      "/"
    end
  end
  
  def mark_as_read!
    update(is_read: true)
  end
end