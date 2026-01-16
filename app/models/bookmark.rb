class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :item, polymorphic: true, counter_cache: true
  belongs_to :route, -> { where(bookmarks: { item_type: 'Route' }) }, foreign_key: 'item_id', optional: true
  belongs_to :venue, -> { where(bookmarks: { item_type: 'Venue' }) }, foreign_key: 'item_id', optional: true

  # Валидации

  validates :user_id, uniqueness: {
    scope: %i[item_type item_id],
    message: 'すでに保存済みです'
  }
  validates :collection_name, length: { maximum: 100 }
  validates :user_id, uniqueness: {
    scope: %i[item_type item_id],
    message: 'すでに保存済みです'
  }

  # スコープ
  scope :venues, -> { where(item_type: 'Venue') }
  scope :routes, -> { where(item_type: 'Route') }
  scope :in_collection, ->(name) { where(collection_name: name) }

  # デフォルトコレクション名
  COLLECTIONS = ['Want to Visit', 'Favorites', 'Hidden Gems'].freeze

  private

  def create_bookmark_notification
    # Уведомляем автора контента (маршрута), что его работу сохранили
    NotificationService.notify_bookmark(self)
  end
end
