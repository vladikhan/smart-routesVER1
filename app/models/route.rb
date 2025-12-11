class Route < ApplicationRecord
  belongs_to :user
  belongs_to :city
  
  # Validations
  validates :name, presence: true
  validates :city, presence: true  # ✓ Simple and correct
  
  # Associations
  has_many :route_items, dependent: :destroy
  has_many :venues, through: :route_items
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags
  
  # Scopes
  scope :public_routes, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Counters
  def increment_view_count
    increment!(:view_count)
  end
end
