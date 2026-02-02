module Follower::Contract
  class Create < Reform::Form
    property :follower_id
    property :following_id

    validates :follower_id, :following_id, presence: true
    validate :cannot_follow_self

    def cannot_follow_self
      errors.add(:follower_id, '自分自身をフォローすることはできません') if follower_id == following_id
    end
  end
end