
class Venue < ApplicationRecord
  belongs_to :district
  belongs_to :user, optional: true
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :route_items, dependent: :destroy
  has_many :routes, through: :route_items
  has_many :bookmarks, dependent: :destroy
  has_many :venue_photos, dependent: :destroy
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags
  

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true
  validates :venue_type, presence: true
  validates :description, length: { maximum: 1000 }

  scope :featured, -> { where(is_featured: true).order(featured_order: :asc) }
  scope :approved, -> { where(status: 'approved') }
  scope :popular, -> { order(popularity_score: :desc) }

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.view_count ||= 0
    self.save_count ||= 0
    self.popularity_score ||= 0.0
    self.reviews_count ||= 0
    self.likes_count ||= 0
    self.average_rating ||= 0.0
    self.status ||= 'approved'
  end

  # Координаты - алиасы для geo_lat/geo_lng
  def latitude
    read_attribute(:latitude).presence || geo_lat
  end

  def latitude=(value)
    self.geo_lat = value
    write_attribute(:latitude, value) if has_attribute?(:latitude)
  end

  def longitude
    read_attribute(:longitude).presence || geo_lng
  end

  def longitude=(value)
    self.geo_lng = value
    write_attribute(:longitude, value) if has_attribute?(:longitude)
  end

  def city
    district&.city
  end

  def calculate_average_rating
    avg = reviews.average(:total_score).to_f
    update_column(:average_rating, avg.round(1))
    avg
  end

  def increment_view_count
    increment!(:view_count)
  end

  def bookmarked_by?(user)
    return false unless user
    bookmarks.exists?(user_id: user.id)
  end
end
