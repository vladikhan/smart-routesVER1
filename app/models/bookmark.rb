class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :item, polymorphic: true, counter_cache: true
  belongs_to :route, -> { where(bookmarks: { item_type: 'Route' }) }, foreign_key: 'item_id', optional: true
  belongs_to :venue, -> { where(bookmarks: { item_type: 'Venue' }) }, foreign_key: 'item_id', optional: true


  validates :user_id, uniqueness: {
    scope: %i[item_type item_id],
    message: 'すでに保存済みです'
  }
  validates :collection_name, length: { maximum: 100 }, allow_blank: true
  

  scope :venues, -> { where(item_type: 'Venue') }
  scope :routes, -> { where(item_type: 'Route') }

  COLLECTIONS = ['Want to Visit', 'Favorites', 'Hidden Gems'].freeze

  private
end
