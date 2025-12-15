class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :venue, optional: true
  
  validates :route, presence: true
  validates :order_index, presence: true, 
            numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(:order_index) }
  
  # Если venue не указан, можно использовать прямые координаты
  def latitude
    super || venue&.latitude
  end
  
  def longitude
    super || venue&.longitude
  end
  
  def display_name
    venue&.name || name || "Location #{order_index + 1}"
  end
end
