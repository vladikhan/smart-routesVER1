class ReviewImage < ApplicationRecord
  belongs_to :review

  # Active Storage
  has_one_attached :image

  validates :position, numericality: { only_integer: true, greater_than: 0 }
  validates :image, presence: true
end
