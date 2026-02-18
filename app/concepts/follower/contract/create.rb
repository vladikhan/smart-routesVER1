module Follower::Contract
  class Create < Reform::Form
    property :follower_id
    property :following_id

    validates :follower_id, :following_id, presence: true
    validate :cannot_follow_self
    validate :user_must_exist
    validate :already_following

    

    def cannot_follow_self
      errors.add(:following_id, '自分自身をフォローすることはできません') if follower_id == following_id
    end

    def user_must_exist
      unless User.exists?(id: following_id)
        errors.add(:following_id, 'ユーザーが存在しません')
      end
    end

    def already_following
      return if follower_id.blank? || following_id.blank?
      if Follower.exists?(follower_id: follower_id, following_id: following_id)
        errors.add(:following_id, 'すでにフォローしています')

      end
    end
  end
end