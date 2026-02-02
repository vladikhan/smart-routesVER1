module Route::Contract::Create
  class Update < Reform::Form
    property :name
    property :description
    property :city_id
    property :estimated_cost
    property :estimated_duration
    property :images, virtual: true

    validates :name, presence: true, length: { maximum: 100 }
    validates :description, length: { maximum: 5000 }
    validates :user, presence: true
    validates :city, presence: true
    validates :view_count, numericality: { greater_than_or_equal_to: 0 }
    validate :images_count_within_limit
  end
end
