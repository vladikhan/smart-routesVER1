class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true
  belongs_to :user

  validates :total_score, numericality: {}, allow_nil: true
  validates :text, presence: true, length: { maximum: 1000 }
end
