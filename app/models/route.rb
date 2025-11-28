class Route < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true

  has_many :route_items, -> { order(position: :asc) }, dependent: :destroy
  has_many :venues, through: :route_items, source: :item, source_type: 'Venue'
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :item, dependent: :destroy
  has_many :bookmarks, as: :item, dependent: :destroy
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags

  # バリデーション
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 500 } 
  validates :estimated_duration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :difficulty_level, inclusion: { in: %w[easy medium hard] }, allow_nil: true 
  validates :user, presence: true

  #Default values
  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.view_count ||= 0 
    self.is_public = true if is_public.nil?
  end

  #Average rating 
  def avarage_rating
    reviews.average(:total_score).to_f.round(1)
  end

  #Total reviews count
  def reviews_count
    reviews.count
  end

  #Check if user has bookmarkes this route
  def bookmarked_by?(user)
    return false unless user
    bookmarks.exists?(user_id: user.id)
  end

  # スコープ
  scope :public_routes, -> { where(is_public: true, is_deleted: false) }
  scope :featured, -> { where(is_featured: true).order(featured_order: :asc) }
  scope :popular, -> { order(popularity_score: :desc) }

  # メソッド
  def average_rating
    reviews.average(:total_score).to_f.round(1)
  end

  accepts_nested_attributes_for :route_items, allow_destroy: true
end
