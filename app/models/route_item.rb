class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :item, polymorphic: true, optional: true
  # Эта ассоциация уже создает метод venue_id и venue
  belongs_to :venue, optional: true 

  validates :route, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :geo_lat, :geo_lng, presence: true, allow_nil: true

  scope :ordered, -> { order(:position) }

  # Проксируем методы к полиморфному item
  delegate :name, :address, :latitude, :longitude, to: :item, allow_nil: true

  def actual_venue
    item if item_type == 'Venue'
  end

  def venue?
    item_type == 'Venue'
  end

  def display_name
    # Используем безопасную навигацию &.
    (venue? ? item.name : name) || "Location #{position + 1}"
  end
end