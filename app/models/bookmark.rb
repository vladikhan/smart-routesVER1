class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :item, polymorphic: true
  belongs_to :route, counter_cache: true

  validates :user_id, uniqueness: {
    scope: [:item_type, :item_id],
    message: "すでに保存済みです" 
  }
  validates :collection_name, length: { maximum: 100 }

    # スコープ
  scope :venues, -> { where(item_type: 'Venue') }
  scope :routes, -> { where(item_type: 'Route') }
  scope :in_collection, ->(name) { where(collection_name: name) }

    # デフォルトコレクション名
  COLLECTIONS = ['Want to Visit', 'Favorites', 'Hidden Gems'].freeze
end
