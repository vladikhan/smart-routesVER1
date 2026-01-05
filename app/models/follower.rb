class Follower < ApplicationRecord
  belongs_to :follower_user_id, class_name: "User", foreign_key: "follower_id"
  belongs_to :follower_user, class_name: 'User', foreign_key: "following_id"

  validates :follower_id, uniqueness: { scope: :following_id, message: "すでにフォローしています" }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:base, "自分自身をフォローできません") if follower_id == following_id
  end
end
