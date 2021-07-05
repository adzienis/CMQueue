class ClearNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    Notification.find(notification_id).mark_as_read!
  end
end
