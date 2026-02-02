class User < ApplicationRecord
  # === Devise & Auth ===
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  mount_uploader :avatar, AvatarUploader

  # === Валидации ===
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :bio, length: { maximum: 500 }, allow_blank: true

  # === Ассоциации: Контент ===
  has_many :routes, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_routes, through: :bookmarks, source: :item, source_type: 'Route'

  # === Ассоциации: Уведомления ===
  has_many :notifications, dependent: :destroy
  has_many :sent_notifications, class_name: 'Notification', foreign_key: :actor_id, dependent: :destroy
  has_many :activities, dependent: :destroy

  # === Ассоциации: DM ===
  has_many :sent_dm_rooms, class_name: 'DmRoom', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_dm_rooms, class_name: 'DmRoom', foreign_key: 'receiver_id', dependent: :destroy
  has_many :dm_messages, dependent: :destroy

  # === Ассоциации: Follow System ===
  # Те, на кого я подписан
  has_many :following_relationships, class_name: 'Follower', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :following_relationships, source: :following_user

  # Мои подписчики
  has_many :follower_relationships, class_name: 'Follower', foreign_key: 'following_id', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower_user

  # === Verification Logic ===
  VERIFICATION_CODE_LENGTH = 6
  VERIFICATION_CODE_EXPIRY = 15.minutes

  def generate_verification_code
    code = SecureRandom.random_number(10**VERIFICATION_CODE_LENGTH).to_s.rjust(VERIFICATION_CODE_LENGTH, '0')
    update_columns(verification_code: code, verification_code_sent_at: Time.current)
    code
  end

  def verification_code_valid?(code)
    return false if verification_code.blank? || verification_code_sent_at.nil?
    Time.current <= verification_code_sent_at + VERIFICATION_CODE_EXPIRY && verification_code == code
  end

  def send_confirmation_instructions
    generate_verification_code
    UserMailer.verification_code_email(self).deliver_now
  end

  # === Messages and Notifications ===
def unread_notifications_count
  # Rails кэширует простые count запросы, но можно добавить явный кэш
  Rails.cache.fetch("user_#{id}_unread_notifications", expires_in: 1.minute) do
    notifications.unread.count
  end
end

  def unread_messages_count
    (sent_dm_rooms.sum(:unread_count_sender) || 0) + (received_dm_rooms.sum(:unread_count_receiver) || 0)
  end

  def dm_rooms
    DmRoom.where('sender_id = ? OR receiver_id = ?', id, id).order(last_message_at: :desc)
  end

  # === Follow System Helpers ===
  def following?(other_user)
    following_relationships.exists?(following_id: other_user.id)
  end

  def follow(other_user)
    return false if self == other_user
    following_relationships.find_or_create_by(following_id: other_user.id) { |f| f.status = 'accepted' }
  end

  def unfollow(other_user)
    following_relationships.find_by(following_id: other_user.id)&.destroy
  end

  # === Feed & Interactions ===
  def feed_routes
    following_ids = following_relationships.pluck(:following_id)
    Route.where(user_id: following_ids + [id]).public_routes.recent
  end

  def liked?(likeable)
    likes.exists?(likeable_type: likeable.class.name, likeable_id: likeable.id)
  end

  def bookmarked?(item)
    bookmarks.exists?(item_type: item.class.name, item_id: item.id)
  end

  # === Helpers ===
  def avatar_url
    avatar.present? ? avatar.url : '/images/default_avatar.png'
  end

  def admin?
    respond_to?(:is_admin) && is_admin
  end

  def confirmed?
    respond_to?(:email_verified) ? email_verified : super
  end
end