class ClearNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Notification.unread.each do |notification|
      notification.mark_as_read!
    end
  end
end
