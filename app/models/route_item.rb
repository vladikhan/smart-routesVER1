class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :item, polymorphic: true, optional: true
  # belongs_to :venue, optional: true 

  validates :route, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  scope :ordered, -> { order(:position) }

  # def actual_venue
  # #   item if item_type == 'Venue'
  # end

  def venue?
    read_attribute(:item_type).to_s.classify == 'Venue'
  end

  def item_type
    value = read_attribute(:item_type)
    value.present? ? value.classify : value
  end

  def display_name
    venue_address.presence || item&.try(:address)
  end
end
