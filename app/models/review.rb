class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reviewable, polymorphic: true

  has_many :review_images, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_one :review_response, dependent: :destroy

  # バリデーション
  validates :text, presence: true, length: { minimum: 10, maximum: 5000 }
  validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { scope: [ :reviewable_type, :reviewable_id], message: "すでにレビューを投稿しています" }

  accepts_nested_attributes_for :review_images, allow_destroy: true

  # コールバック
  # after_create :update_reviewable_rating
  # after_update :update_reviewable_rating
  # after_destroy :update_reviewable_rating

  private

  
end