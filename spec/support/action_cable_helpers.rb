module ActionCableHelpers
    # Helper для проверки broadcasts
  def expect_broadcast_to_room(room_id, data = {})
  expect {
    yield
}.to have_broadcasted_to("dm_room_#{room_id}").with(
  hash_including(data)
)
  end

  def expect_notification_broadcast(user_id, notification_type)
    expect {
      yield
  }.to have_broadcasted_to("notifications_#{user_id}").with(
    hash_including(type: notification_type)
  )
  end
end
RSpec.configure do |config|
  config.include ActionCableHelpers, type: :request
  config.include ActionCableHelpers, type: :channel
  
    # Включаем ActionCable test helpers
  config.include ActionCable::TestHelper

end
  