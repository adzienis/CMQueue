class PingJob < ApplicationJob
  queue_as :default

  # TODO: thread if this is slow
  def perform
    User.in_batches do |batch|
      active_ids = []
      inactive_ids = []
      batch.each do |user|
        if user_active?(user)
          active_ids << user.id
        else
          inactive_ids << user.id
        end
      end

      User.where(id: active_ids).update_all(last_pinged_at: Time.current.utc, last_active_at: Time.current.utc)
      User.where(id: inactive_ids).update_all(last_pinged_at: Time.current.utc)
    end
  end

  private

  def user_active?(user)
    SiteChannel.broadcast_to(user, {
      type: 'ping',
      message: 'ping'
    }).positive?
  end
end
