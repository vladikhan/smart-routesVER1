class Follower < ApplicationRecord
  # Твои названия из базы: follower_id и following_id
  belongs_to :follower_user, class_name: 'User', foreign_key: 'follower_id'
  belongs_to :following_user, class_name: 'User', foreign_key: 'following_id'

  after_create_commit :increment_counters
  after_destroy_commit :decrement_counters

  private

  def increment_counters
    # Rails метод increment_counter ищет колонку по имени :following_count в таблице users
    User.increment_counter(:following_count, follower_id)
    User.increment_counter(:followers_count, following_id)
  end

  def decrement_counters
    User.decrement_counter(:following_count, follower_id)
    User.decrement_counter(:followers_count, following_id)
  end
end
