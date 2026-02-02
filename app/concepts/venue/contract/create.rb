module Venue::Contract
  class Create < Reform::Form
    property :name
    property :address
    property :venue_type
    property :description
    property :district_id
    property :geo_lat
    property :geo_lng
    property :photos

    validates :name, presence: true, length: { maximum: 100 }
    validates :address, presence: true
    validates :venue_type, presence: true
    validates :description, length: { maximum: 1000 }
    validates :district_id, presence: true
  end
end
