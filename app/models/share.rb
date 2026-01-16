class Share < ApplicationRecord
  belongs_to :user
  belongs_to :route

  has_one :notification, as: :notifiable, dependent: :destroy
  after_create :create_notification

  private

  def create_notification
    Notification.create(
      user: route.user,
      notifiable: self,
      is_read: false
    )
  end
end
