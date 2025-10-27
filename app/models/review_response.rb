class ReviewResponse < ApplicationRecord
  belongs_to :review
  belongs_to :user   # 通常はビジネスオーナー

  validates :text, presence: true, length: {minimum: 10, maximum: 2000 }
  validates :review_id, uniqueness: { message: "このレビューには既に返信済みです" }

  #コールバク
  after_create :notify_reviewer

  private
  
  def notify_reviewer
    Notification.create(
      user: reviewer.user,
      actor: user,
      notification_type: 'review_response',
      entity: review
    )
  end
end
