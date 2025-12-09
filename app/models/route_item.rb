class RouteItem < ApplicationRecord
  belongs_to :route
  belongs_to :venue
  belongs_to :item, polymorphic: true

  validates :position, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validates :item_type, presence: true, inclusion: { in: %w[venue activity break custom] }

  # Set default item_type
  after_initialize :set_default_item_type, if: :new_record?

  default_scope { order(position: :asc) }

  private

  def set_default_item_type
    self.item_type ||= 'venue'
  end
end
