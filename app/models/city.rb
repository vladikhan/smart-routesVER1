class City < ApplicationRecord
  has_many :districts, dependent: :destroy
  has_many :venues, through: :districts

  validates :name, presence: true, uniqueness: true	
end
