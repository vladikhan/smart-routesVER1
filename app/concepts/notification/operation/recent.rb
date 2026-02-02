module Notification::Operation
  class Recent < Trailblazer::Operation
    step :fetch_notifications!

    def fetch_notifications!(ctx, current_user:, **)
      ctx[:model] = current_user.notifications
                                .includes(:actor, :notifiable)
                                .order(created_at: :desc)
                                .limit(8)
    end
  end
end