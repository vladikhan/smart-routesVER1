class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :item, polymorphic: true

  validates :position, presence: true

  validates :duration_minutes,
            numericality: { greater_than: 0 },
            allow_nil: true

  validates :item_type,
            inclusion: {
              in: %w[Venue Activity Restaurant Cafe Landmark Market Attraction Custom],
              message: "%{value} is not a valid item type"
            }

  before_validation :set_default_item_type

  private

  def set_default_item_type
    self.item_type ||= item.class.name if item
  end
end