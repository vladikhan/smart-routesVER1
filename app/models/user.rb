class User < ApplicationRecord
	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :confirmable 
	# リレーション
 has_many :routes, dependent: :destroy
 has_many :reviews, dependent: :destroy
 has_many :comments, dependent: :destroy
 has_many :likes, dependent: :destroy
 has_many :bookmarks, dependent: :destroy
 has_many :notifications, dependent: :destroy

 #DM
	has_many :sent_dm_rooms, class_name: 'DmRoom', foreign_key: 'sender_id', dependent: :destroy
	has_many :received_dm_rooms, class_name: 'DmRoom', foreign_key: 'receiver_id', dependent: :destroy
	has_many :dm_messages, dependent: :destroy

	# フォロー機能
	has_many :following_relationships, class_name: 'Follower', foreign_key: 'follower_id', dependent: :destroy
	has_many :following, through: :following_relationships, source: :following_user

	has_many :follower_relationships, class_name: 'Follower', foreign_key: 'following_id', dependent: :destroy
	has_many :followers, through: :follower_relationships, source: :follower_user

	# ビジネスアカウント
	has_many :place_owners, dependent: :destroy
	has_many :owned_venues, through: :place_owners, source: :venue

	# バリデーション
	validates :username, presence: true, uniqueness: true, length: { minimum:3, maximum: 30 }
	validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
	validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

	# メソッド
	def following?(user)
		following.include?(user)
	end

	def admin?
		is_admin
	end
end
