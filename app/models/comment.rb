class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  belongs_to :parent, class_name: 'Comment', optional: true

  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validates :text, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :user_id, presence: true

  after_create_commit :create_comment_notification
  after_destroy_commit :remove_comment_notification

  scope :recent, -> { order(created_at: :desc) }

  private

  def create_comment_notification
    NotificationService.notify_comment_added(self)
  end

  def remove_comment_notification
    NotificationService.remove_notification(self)
  end
end
