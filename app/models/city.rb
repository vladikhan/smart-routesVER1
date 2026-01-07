class City < ApplicationRecord
  has_many :districts, dependent: :destroy
  has_many :venues, through: :districts
  has_many :routes

  validates :name, presence: true, uniqueness: true
end
