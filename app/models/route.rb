class Route < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true

  has_many :route_items, dependent: :destroy
  has_many :venues, through: :route_items, source: :item, source_type: 'Venue'

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :likers, through: :likes, source: :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reviews, as: :reviewable, dependent: :destroy

  has_many :bookmarks, as: :item, dependent: :destroy
  has_many :bookmarkers, through: :bookmarks, source: :user

  has_many :notifications, as: :notifiable, dependent: :destroy

  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [300, 300]
    attachable.variant :medium, resize_to_limit: [800, 600]
    attachable.variant :large, resize_to_limit: [1200, 900]
  end

  accepts_nested_attributes_for :route_items, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 5000 }
  validates :user, presence: true
  validates :city, presence: true
  validates :view_count, numericality: { greater_than_or_equal_to: 0 }
  validate :images_count_within_limit

  # === Колбэки ===
  before_create :initialize_view_count
  # Уведомляем подписчиков после создания маршрута
  after_create_commit :notify_followers_about_new_route

  scope :public_routes, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :trending, -> { order(view_count: :desc) }
  scope :by_city, ->(city_id) { where(city_id: city_id) }
  scope :popular, -> { order(likes_count: :desc) }

  def increment_view_count!
    increment!(:view_count)
  end

  def liked_by?(user)
    return false unless user

    likes.exists?(user_id: user.id)
  end

  def bookmarked_by?(user)
    return false unless user

    bookmarks.exists?(user_id: user.id)
  end

  def average_rating
    reviews.average(:total_score)
  end

  def update_average_rating
    avg = reviews.average(:total_score) || 0
    update_columns({ average_rating: avg.to_f.round(1),
                     reviews_count: reviews.count })
  end

  private

  def initialize_view_count
    self.view_count ||= 0
  end

  def notify_followers_about_new_route
    return unless is_public?

    NotificationService.notify_new_route_from_following(self) if defined?(NotificationService)
  end

  def acceptable_images
    return unless images.attached?

    images.each do |image|
      errors.add(:images, 'は5MB以下である必要があります') unless image.byte_sizw <= 5.megabytes
    end

    acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    return if acceptable_types.include?(image.content_type)

    errors.add(:images, 'はJPEG, PNG, GIF形式である必要があります')
  end

  def images_count_within_limit
    return unless images.attached? && images.count > 10

    errors.add(:images, 'は最大10枚までです')
  end
end
