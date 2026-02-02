module Venue::Contract
  class Update < Reform::Form
    property :name
    property :description
    property :district_id

    property :photos, virtual: true
  end
end
