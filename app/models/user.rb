class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Avatar upload
  mount_uploader :avatar, AvatarUploader

  # Verification code
  VERIFICATION_CODE_LENGTH = 6
  VERIFICATION_CODE_EXPIRY = 15.minutes

  # Generate 6-digit verification code
  def generate_verification_code
    self.verification_code = SecureRandom.random_number(10**VERIFICATION_CODE_LENGTH).to_s.rjust(VERIFICATION_CODE_LENGTH,
                                                                                                 '0')
    self.verification_code_sent_at = Time.current
    save(validate: false)
  end

  # Check if verfication code is valid
  def verification_code_valid?(code)
    return false if verification_code.blank?
    return false if verification_code_sent_at.nil?
    return false if Time.current > verification_code_sent_at + VERIFICATION_CODE_EXPIRY

    verification_code == code
  end

  # Chdeck if code is expired
  def verification_code_expired?
    return true if verification_code_sent_at.nil?

    Time.current > verification_code_sent_at + VERIFICATION_CODE_EXPIRY
  end

  # Send verification code email
  def send_verification_code
    generate_verification_code
    UserMailer.verification_code_email(self).deliver_now
  end

  # Override Devise confirmable to use code instead of link
  def senf_confirmation_instructions
    generate_verification_code
    UserMailer.verification_code_email(self).deliver_now
  end

  # DM
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
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :bio, length: { maximum: 500 }

  # リレーション
  has_many :routes, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # 通知
  has_many :notifications, dependent: :destroy
  has_many :sent_notifications, class_name: 'Notification', foreign_key: :actor_id, dependent: :destroy

  def unread_notifications_count
    notifications.unread.count
  end

  def unread_messages_count
    sent_dm_rooms.sum(:unread_count_sender) +
      received_dm_rooms.sum(:unread_count_receiver)
  end

  # Avatar helper
  def avatar_url
    avatar.present? ? avatar.url : '/images/default_avatar.png'
  end

  # メソッド
  def following?(user)
    following.include?(user)
  end

  def admin?
    is_admin
  end
end

def dm_rooms
  DmRoom.where('sender_id = ? OR receiver_id = ?', id, id)
        .order(last_message_at: :desc)
end

# Для совместимости с Devise confirmable в тестах
def confirmed?
  email_verified
end

def active_for_authentication?
  super && email_verified
end

def inactive_message
  email_verified ? super : :unconfirmed
end
