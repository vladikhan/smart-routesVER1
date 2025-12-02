class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :item, polymorphic: true
  belongs_to :venue, polymorphic: true

  # Алиас для удобства
  def venue
    item if item_type == 'Venue'
  end

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :route_id }
  validates :duration_minutes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :item, presence: true

  def set_defaults
    self.duration_minutes ||= 60
  end
  
    default_scope { order(position: :asc) }

  acts_as_list scope: :route
end
