class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  validates :key, presence: true
end
