class ClearNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Notification.unread.each do |notification|
      notification.mark_as_read!
    end
  end

  after_perform do |_job|
    ClearNotificationsJob.set(wait_until: Time.now.tomorrow.midnight - 5.minutes).perform_later
  end
end
