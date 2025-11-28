class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :item, polymorphic: true
  belongs_to :venue


  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :route_id }
  validates :duration_minutes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    default_scope { order(position: :asc) }

  acts_as_list scope: :route
end
