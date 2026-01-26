class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reviewable, polymorphic: true

  has_many :review_images, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_one :review_response, dependent: :destroy
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    has_many :review_images, dependent: :destroy
  end

  accepts_nested_attributes_for :review_images, allow_destroy: true

  # バリデーション
  validates :text, presence: true, length: { minimum: 10, maximum: 5000 }
  # validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  # validates :user_id, uniqueness: { scope: %i[reviewable_type reviewable_id], message: 'すでにレビューを投稿しています' }

  # コールバック
  after_create_commit :create_review_notification
  after_create_commit :update_reviewable_rating
  after_update_commit :update_reviewable_rating
  after_destroy_commit :remove_review_notification
  after_destroy_commit :update_reviewable_rating

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(total_score: :desc) }

  private

  def create_review_notification
    NotificationService.notify_review_added(self)
  end

  def remove_review_notification
    NotificationService.remove_notification(self)
  end

  def update_reviewable_rating
    return unless reviewable.respond_to?(:update_average_rating)

    Rails.logger.info "🔄 #{reviewable.class.name} ID=#{reviewable.id} の平均評価を更新中"

    reviewable.update_average_rating
  end
end
