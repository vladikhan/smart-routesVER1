class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: 'Comment', optional: true

  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validates :text, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :commentable, presence: true

  scope :top_level, -> { where(parent_id: nil) }
end
