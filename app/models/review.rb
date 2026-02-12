class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true
  belongs_to :user
  has_many :review_images, dependent: :destroy
  has_one :review_response, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates :total_score, numericality: {}, allow_nil: true
  validates :text, presence: true, length: { maximum: 1000 }
end
