class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :item, polymorphic: true
  
  validates :route, presence: true
  validates :order_index, presence: true, 
            numericality: { greater_than_or_equal_to: 0 }

  validates :position, presence: true,
            numericality: { greater_than_or_equal_to: 0}
  
  scope :ordered, -> { order(:order_index) }
  
  # Если venue не указан, можно использовать прямые координаты
  def venue
    item if item_type == "Venue"
  end

  def venue?
    item_type == "Venue"
  end
  
  def name
    item&.name
  end

  def address
    item&.address if item.respond_to?(:address)
  end

  def latitude
    item&.latitude if item.respond_to?(:latitude)
  end
  
  def longitude
    item&.longitude if item.respond_to?(:longitude)
  end
  
  def display_name
    venue&.name || name || "Location #{order_index + 1}"
  end

  def venue?
    item_type == "Venue"
  end

  def venue?
    item if venue?
  end
end
