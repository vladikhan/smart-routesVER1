class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :venue, optional: true
  
  validates :route, presence: true
  validates :position, presence: true, 
            numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(:position) }
  
  # Если venue не указан, можно использовать прямые координаты
  def latitude
    super || venue&.latitude
  end
  
  def longitude
    super || venue&.longitude
  end
  
  def display_name
    venue&.name || name || "Location #{position + 1}"
  end
end
